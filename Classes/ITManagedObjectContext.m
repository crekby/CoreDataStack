//
//  ITManagedObjectContext.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/28/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITManagedObjectContext.h"

@implementation ITManagedObjectContext

- (void)insertObject:(NSManagedObject *)object
{
    [self assertIfNeeded];
    [super insertObject:object];
}

- (void)deleteObject:(NSManagedObject *)object
{
    [self assertIfNeeded];
    [super deleteObject:object];
}

- (BOOL)save:(NSError * _Nullable __autoreleasing *)error
{
    [self assertIfNeeded];
    return [super save:error];
}

- (void)assertIfNeeded
{
    NSAssert(self.concurrencyType != NSMainQueueConcurrencyType, @"Changes in main context is not allowed. Please use background context.");
}

@end
