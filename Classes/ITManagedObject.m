//
//  ITManagedObject.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/28/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITManagedObject.h"

@implementation ITManagedObject

- (void)willChangeValueForKey:(NSString *)key
{
    NSAssert(self.managedObjectContext.concurrencyType != NSMainQueueConcurrencyType, @"Changes in main context is not allowed. Please use background context.");
    [super willChangeValueForKey:key];
}

@end
