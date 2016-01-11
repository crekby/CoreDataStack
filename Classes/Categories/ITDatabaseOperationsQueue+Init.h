//
//  ITDatabaseOperationsQueue+Additions.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/4/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue.h"

@interface ITDatabaseOperationsQueue(Init)

+ (instancetype)newOperationQueueWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType;

- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType;

@end

