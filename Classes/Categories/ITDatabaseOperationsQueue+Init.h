//
//  ITDatabaseOperationsQueue+Additions.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/4/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue.h"

@interface ITDatabaseOperationsQueue(Init)

/**
 Returns new database operations queue instance with given parametrs.
 @param model Model object.
 @param storeName Name for store on file system.
 @param storeType Store type (NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType).
 */
+ (instancetype)newOperationQueueWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType;

/**
 init database operations queue instance with given parametrs.
 @param model Model object.
 @param storeName Name for store on file system.
 @param storeType Store type (NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType).
*/
- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType;

@end

