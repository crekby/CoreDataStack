//
//  ITDatabaseManager.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseManager.h"
#import "ITManagedObjectContext.h"
#import "ITManagedObject.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface ITDatabaseManager()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, strong) NSString *storeType;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation ITDatabaseManager

#pragma mark - Inits

- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType
{
    NSParameterAssert(model);
    NSParameterAssert(storeName);
    NSParameterAssert(storeType);
    
    self = [super init];
    if (self) {
        _model = model;
        _storeType = storeType;
        _storeURL = [[ITDatabaseManager applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
        NSAssert([self initialisePersistenceStore], @"Unable to initialise persistence store");
        NSAssert([self createManagedObjectContexts], @"Unable to create Managed Object Contexts");
        [self swizzleWillChangeValueForKeyInModelEntitiesClasses];
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

- (void)executeMainThreadOperation:(void (^)(NSManagedObjectContext *))mainThreadOperation
{
    NSAssert(mainThreadOperation, @"No Main Thread operation to perform");
    
    [self.mainManagedObjectContext performBlockAndWait:^{
        mainThreadOperation(self.mainManagedObjectContext);
    }];
}

- (void)executeBackgroundOperation:(void (^)(NSManagedObjectContext *))operation
{
    NSAssert(operation, @"No Background operation to perform");
    [self.backgroundManagedObjectContext performBlock:^{
        operation(self.backgroundManagedObjectContext);
    }];
}

- (void)executeBackgroundOperation:(BackroundOperationWithResultBlock)backgroundOperation mainThreadOperation:(MainThreadOperationWithResultBlock)mainThreadOperation
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
    
    [self executeBackgroundOperation:^(NSManagedObjectContext *backgroundContext) {
        
        result = backgroundOperation(backgroundContext);
        
        NSError *error;
        
        [backgroundContext save:&error];
        
        if (error) {
            mainThreadOperationBlock(error, nil);
            return;
        } else {
            if (result.count > 0 && mainThreadOperation) {
                NSArray *objectIDs = [result valueForKey:@"objectID"];
                [self executeMainThreadOperation:^(NSManagedObjectContext *mainThreadContext) {
                    
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
                                                                                 managedObjectContext:self.mainManagedObjectContext
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
    [self.backgroundManagedObjectContext performBlock:^{
        [self clearAllEntitiesInContext:self.backgroundManagedObjectContext];
    }];
}

- (void)clearAllEntitiesAndWait
{
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        [self clearAllEntitiesInContext:self.backgroundManagedObjectContext];
    }];
}

#pragma mark - Helpers

- (BOOL)persistentStoreExistsAtURL:(NSURL *)url
{
    NSError *error;
    BOOL resourceIsReachable = [url checkResourceIsReachableAndReturnError:&error];
    return resourceIsReachable;
}

- (BOOL)isModel:(NSManagedObjectModel *)model compatibleWithPersistentStoreAtURL:(NSURL *)url
{
    // can't be compatible with something that doesn't exist :D
    if (![self persistentStoreExistsAtURL:url]) {
        return NO;
    }
    
    NSError *error;
    NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:self.storeType
                                                                                        URL:url
                                                                                      error:&error];
    
    // If there was an error retrieving the metadata, not compatible
    if (error) {
        return NO;
    }
    
    // If there was no metadata, not compatible
    if (metaData == nil) {
        return NO;
    }
    
    BOOL compatible = [model isConfiguration:nil compatibleWithStoreMetadata:metaData];
    return compatible;
}

#pragma mark - Notifications

- (void)mainContextDidSave:(NSNotification *)notification
{
    [self.backgroundManagedObjectContext performBlock:^{
        [self.backgroundManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (void)backgroundContextDidSave:(NSNotification *)notification
{
    [self.mainManagedObjectContext performBlock:^{
        NSArray* updated = [notification.userInfo valueForKey:NSUpdatedObjectsKey];
        // Fault all objects that will be updated.
        for (NSManagedObject* obj in updated) {
            NSManagedObject* mainThreadObject = [self.mainManagedObjectContext existingObjectWithID:obj.objectID error:nil];
            [mainThreadObject willAccessValueForKey:nil];
        }
        
        [self.mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

#pragma mark - Private Methods

- (void)swizzleWillChangeValueForKeyInModelEntitiesClasses
{
    for (NSEntityDescription *description in self.model.entities) {
        Class entityClass = NSClassFromString(description.managedObjectClassName);
        if (!entityClass) {
            continue;
        }
        SEL sel = @selector(willChangeValueForKey:);
        Method origMethod = class_getInstanceMethod(entityClass, sel);
        Method newMethod = class_getInstanceMethod(ITManagedObject.class, sel);
        if(!class_addMethod(entityClass, sel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
}

- (BOOL)initialisePersistenceStore
{
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    if (!self.persistentStoreCoordinator) {
        return NO;
    }

    BOOL exists = [self persistentStoreExistsAtURL:self.storeURL];
    if (exists) {
        BOOL compatible = [self isModel:self.model compatibleWithPersistentStoreAtURL:self.storeURL];
        if (!compatible) {
            return NO;
        }
    }
    
    NSDictionary *storeOptions = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                   NSInferMappingModelAutomaticallyOption:@YES};
    
    NSError *error;
    [self.persistentStoreCoordinator addPersistentStoreWithType:self.storeType
                                                  configuration:nil
                                                            URL:self.storeURL
                                                        options:storeOptions
                                                          error:&error];
    
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)createManagedObjectContexts
{
    self.backgroundManagedObjectContext = [[ITManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.backgroundManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [self.backgroundManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.backgroundManagedObjectContext setName:@"ITDatabaseManager.BackgroundQueue"];
    
    self.mainManagedObjectContext = [[ITManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [self.mainManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.mainManagedObjectContext setName:@"ITDatabaseManager.MainQueue"];
    
    if (!self.mainManagedObjectContext || !self.backgroundManagedObjectContext) {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.mainManagedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.backgroundManagedObjectContext];
    
    return YES;
}

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
