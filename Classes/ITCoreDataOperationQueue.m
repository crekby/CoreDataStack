//
//  ITDatabaseManager.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue.h"
#import "ITCoreDataOperationQueue+Logging.h"
#import "ITCoreDataOperationQueue+Private.h"
#import <CoreData/CoreData.h>

@interface ITCoreDataOperationQueue()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *readOnlyContext;
@property (nonatomic, strong) NSManagedObjectContext *changesContext;

@end

@implementation ITCoreDataOperationQueue

#pragma mark - Inits

- (instancetype)initWithModel:(NSManagedObjectModel*)model managedObjectContext:(NSManagedObjectContext*)context readOnlyManagedObjectContext:(NSManagedObjectContext*)readOnlyContext
{
    NSParameterAssert(context);
    NSParameterAssert(model);
    NSParameterAssert(readOnlyContext);
    self = [super init];
    if (self) {
        _readOnlyContext = readOnlyContext;
        _changesContext = context;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
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
    
    [self.readOnlyContext performBlockAndWait:^{
        mainThreadOperation(self.readOnlyContext);
    }];
}

- (void)executeOperation:(void (^)(NSManagedObjectContext *))operation
{
    NSAssert(operation, @"No Background operation to perform");
    [self.changesContext performBlock:^{
        operation(self.changesContext);
        NSError *error;
        [self.changesContext save:&error];
        [self logError:error];
    }];
}

- (void)executeOperation:(BackroundOperationWithResultBlock)backgroundOperation mainThreadOperation:(MainThreadOperationWithResultBlock)mainThreadOperation
{
    NSAssert(backgroundOperation, @"No Background operation to perform");
    
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
            [self logError:error];
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
                    [self logError:error];
                    mainThreadOperationBlock(error, result);
                }];
            } else {
                mainThreadOperationBlock(nil, nil);
            }
        }
    }];
}

#pragma mark - Notifications

- (void)contextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = notification.object;
    if ([context isEqual:self.readOnlyContext]) {
        NSAssert(NO, @"This is readonly context use another context");
    } else if ([context isEqual:self.changesContext]) {
        [self.readOnlyContext performBlock:^{
            if (self.readOnlyContext.hasChanges) {
                [self.readOnlyContext rollback];
            }
            NSArray* updated = [notification.userInfo valueForKey:NSUpdatedObjectsKey];
            // Fault all objects that will be updated.
            for (NSManagedObject* obj in updated) {
                NSError *error;
                NSManagedObject* mainThreadObject = [self.readOnlyContext existingObjectWithID:obj.objectID error:&error];
                [self logError:error];
                [mainThreadObject willAccessValueForKey:nil];
            }
            
            [self.readOnlyContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

@end
