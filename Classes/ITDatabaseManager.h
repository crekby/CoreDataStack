//
//  ITDatabaseManager.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ITManagedObjectContext;

@interface ITDatabaseManager : NSObject

@property (nonatomic, strong, readonly) ITManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readonly) ITManagedObjectContext *backgroundManagedObjectContext;

/**
 URL to Documents directory in application sandbox.
 */
+ (NSURL *)applicationDocumentsDirectory;

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns Database manager instance with given parametrs.
 @param model Model object.
 @param storeName Name for store on file system.
 @param storeType Store type (NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType).
 */
- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType NS_DESIGNATED_INITIALIZER;

/**
 Executes given block in main trhead. 
 @warning DO NOT USE MAIN THREAD CONTEXT FOR CHANGES, USE IT ONLY FOR FETCHING.
 @param backgroundOperation Block for execution.
 */
- (void)executeMainThreadOperation:(void (^)(NSManagedObjectContext *))mainThreadOperation;

/**
 Executes given block in background.
 @warning USE BACKGROUND CONTEXT FOR MAKING CHANGES IN YOUR MODEL, NOT MAIN CONTEXT.
 @param backgroundOperation Block for execution.
 */
- (void)executeBackgroundOperation:(void (^)(NSManagedObjectContext *))backgroundOperation;

@end
