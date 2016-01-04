//
//  ITDatabaseManager.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue.h"
#import <CoreData/CoreData.h>

@interface ITDatabaseOperationsQueue()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *readOnlyContext;
@property (nonatomic, strong) NSManagedObjectContext *changesContext;
@property (nonatomic, strong) NSString *storeType;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation ITDatabaseOperationsQueue

#pragma mark - Inits

- (instancetype)initWithPersistenceStoreCoordinator:(NSPersistentStoreCoordinator*)storeCoordinator managedObjectContext:(NSManagedObjectContext*)context readOnlyManagedObjectContext:(NSManagedObjectContext*)readOnlyContext
{
    NSParameterAssert(storeCoordinator);
    NSParameterAssert(context);
    NSParameterAssert(readOnlyContext);
    self = [super init];
    if (self) {
        _persistentStoreCoordinator = storeCoordinator;
        _readOnlyContext = readOnlyContext;
        _changesContext = context;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mainContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:readOnlyContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:context];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Class Methods

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Public

- (void)executeReadOnlyOperation:(void (^)(NSManagedObjectContext *))mainThreadOperation
{
    NSAssert(mainThreadOperation, @"No Main Thread operation to perform");
    
    [self.readOnlyContext performBlockAndWait:^{
        mainThreadOperation(self.readOnlyContext);
    }];
}

- (void)executeOperation:(void (^)(NSManagedObjectContext *))operation
{
    NSAssert(operation, @"No Background operation to perform");
    [self.changesContext performBlock:^{
        operation(self.changesContext);
    }];
}

- (void)executeOperation:(BackroundOperationWithResultBlock)backgroundOperation readOnlyOperation:(MainThreadOperationWithResultBlock)mainThreadOperation
{
    NSAssert(backgroundOperation, @"No Background operation to perform");
    NSAssert(mainThreadOperation, @"No Main Thread operation to perform");
    
    void (^mainThreadOperationBlock) (NSError *, NSArray *) = ^(NSError *error, NSArray *array) {
        if (mainThreadOperation) {
            if ([NSThread isMainThread]) {
                mainThreadOperation(error, array);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    mainThreadOperation(error, array);
                });
            }
        }
    };
    
    NSArray __block *result;
    
    [self executeOperation:^(NSManagedObjectContext *backgroundContext) {
        
        result = backgroundOperation(backgroundContext);
        
        NSError *error;
        
        if (backgroundContext.hasChanges) {
            [backgroundContext save:&error];
        }
        
        if (error) {
            mainThreadOperationBlock(error, nil);
            return;
        } else {
            if (result.count > 0 && mainThreadOperation) {
                NSArray *objectIDs = [result valueForKey:@"objectID"];
                [self executeReadOnlyOperation:^(NSManagedObjectContext *mainThreadContext) {
                    
                    // Fetch Main Thread Objects
                    NSString *entity = ((NSManagedObject*)[result firstObject]).entity.name;
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
                    request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@",objectIDs];
                    request.includesSubentities = NO;
                    NSError *error;
                    NSArray *result = [mainThreadContext executeFetchRequest:request error:&error];
                    
                    mainThreadOperationBlock(error, result);
                }];
            } else {
                mainThreadOperationBlock(nil, nil);
            }
        }
    }];
}

#pragma mark FetchResultController

- (NSFetchedResultsController *)controllerWithRequest:(NSFetchRequest *)request
                                   sectionKeyPathName:(NSString *)keyPath
                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    NSAssert([request.sortDescriptors count] > 0, @"NSFetchedResultController requres sort descriptors.");
    NSAssert(request.resultType == NSManagedObjectResultType, @"NSFetchedResultController requires NSManagedObject Result Type");
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:self.readOnlyContext
                                                                                   sectionNameKeyPath:keyPath
                                                                                            cacheName:nil];
    controller.delegate = delegate;
    NSError *error;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;
}

- (NSFetchedResultsController*)controllerWithRequest:(NSFetchRequest *)request
                                         andDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
{
    return [self controllerWithRequest:request sectionKeyPathName:nil delegate:delegate];
}

#pragma mark Deleting all entities

- (void)clearAllEntities
{
    [self.changesContext performBlock:^{
        [self clearAllEntitiesInContext:self.changesContext];
    }];
}

- (void)clearAllEntitiesAndWait
{
    [self.changesContext performBlockAndWait:^{
        [self clearAllEntitiesInContext:self.changesContext];
    }];
}

#pragma mark - Notifications

- (void)mainContextDidSave:(NSNotification *)notification
{
    [self.readOnlyContext performBlock:^{
        [self.changesContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (void)backgroundContextDidSave:(NSNotification *)notification
{
    [self.readOnlyContext performBlock:^{
        if (self.readOnlyContext.hasChanges) {
            [self.readOnlyContext rollback];
        }
        NSArray* updated = [notification.userInfo valueForKey:NSUpdatedObjectsKey];
        // Fault all objects that will be updated.
        for (NSManagedObject* obj in updated) {
            NSManagedObject* mainThreadObject = [self.readOnlyContext existingObjectWithID:obj.objectID error:nil];
            [mainThreadObject willAccessValueForKey:nil];
        }
        
        [self.readOnlyContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

#pragma mark - Private Methods

- (void)clearAllEntitiesInContext:(NSManagedObjectContext *)context
{
    NSArray *allEntities = self.model.entities;
    
    [allEntities enumerateObjectsUsingBlock:^(NSEntityDescription *entityDescription, NSUInteger idx, BOOL *stop) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityDescription.name];
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        if (!error) {
            for (NSManagedObject *object in results) {
                [context deleteObject:object];
            }
        }
    }];
    [context save:nil];
}

@end
