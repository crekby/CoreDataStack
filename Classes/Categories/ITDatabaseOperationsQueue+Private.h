//
//  ITDatabaseOperationsQueue+Private.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue.h"

@interface ITDatabaseOperationsQueue(Private)

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *readOnlyContext;
@property (nonatomic, strong) NSManagedObjectContext *changesContext;

@end
