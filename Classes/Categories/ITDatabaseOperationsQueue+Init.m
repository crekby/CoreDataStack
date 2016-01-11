//
//  ITDatabaseOperationsQueue+Additions.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/4/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue+Init.h"

@implementation ITDatabaseOperationsQueue(Init)

+ (instancetype)newOperationQueueWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType
{
    return [[self alloc] initWithModel:model storeName:storeName storeType:storeType];
}

- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType
{
    NSParameterAssert(model);
    NSParameterAssert(storeName);
    NSParameterAssert(storeType);
    
    NSPersistentStoreCoordinator *storeCoordinator = [self newPersistenceStoreCoordinatorWithModel:model storeType:storeType storeName:storeName];
    
    NSManagedObjectContext *backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [backgroundManagedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    [backgroundManagedObjectContext setName:@"ITDatabaseManager.BackgroundQueue"];
    
    NSManagedObjectContext *mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [mainManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [mainManagedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    [mainManagedObjectContext setName:@"ITDatabaseManager.MainQueue"];
        
    self = [self initWithModel:model managedObjectContext:backgroundManagedObjectContext readOnlyManagedObjectContext:mainManagedObjectContext];
    return self;
}

- (NSPersistentStoreCoordinator*)newPersistenceStoreCoordinatorWithModel:(NSManagedObjectModel*)model storeType:(NSString*)storeType storeName:(NSString*)storeName
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *storeURL = [[ITDatabaseOperationsQueue applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
    BOOL exists = [self persistentStoreExistsAtURL:storeURL];
    if (exists) {
        BOOL compatible = [self isModel:model compatibleWithPersistentStoreAtURL:storeURL storeType:storeType];
        if (!compatible) {
            return nil;
        }
    }
    
    NSDictionary *storeOptions = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                   NSInferMappingModelAutomaticallyOption:@YES};
    
    NSError *error;
    [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:storeOptions
                                                          error:&error];
    
    return persistentStoreCoordinator;
}

#pragma mark - Helpers

- (BOOL)persistentStoreExistsAtURL:(NSURL *)url
{
    NSError *error;
    BOOL resourceIsReachable = [url checkResourceIsReachableAndReturnError:&error];
    return resourceIsReachable;
}

- (BOOL)isModel:(NSManagedObjectModel *)model compatibleWithPersistentStoreAtURL:(NSURL *)url storeType:(NSString*)storeType
{
    if (![self persistentStoreExistsAtURL:url]) {
        return NO;
    }
    
    NSError *error;
    NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType
                                                                                        URL:url
                                                                                      error:&error];
    
    if (error) {
        return NO;
    }
    
    if (metaData == nil) {
        return NO;
    }
    
    BOOL compatible = [model isConfiguration:nil compatibleWithStoreMetadata:metaData];
    return compatible;
}

@end

