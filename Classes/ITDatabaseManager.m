//
//  ITDatabaseManager.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseManager.h"
#import <CoreData/CoreData.h>

@interface ITDatabaseManager()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
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

#pragma mark - Private Methods

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

@end
