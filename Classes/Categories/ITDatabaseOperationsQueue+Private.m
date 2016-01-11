//
//  ITDatabaseOperationsQueue+Private.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue+Private.h"
#import <objc/runtime.h>

static char kITModelKey;
static char kITReadOnlyContextKey;
static char kITChangesContextKey;

@implementation ITDatabaseOperationsQueue(Private)

- (void)setModel:(NSManagedObjectModel *)model
{
    objc_setAssociatedObject(self, &kITModelKey, model, OBJC_ASSOCIATION_RETAIN);
}

- (NSManagedObjectModel *)model
{
    return objc_getAssociatedObject(self, &kITModelKey);
}

- (void)setReadOnlyContext:(NSManagedObjectContext *)readOnlyContext
{
    objc_setAssociatedObject(self, &kITReadOnlyContextKey, readOnlyContext, OBJC_ASSOCIATION_RETAIN);
}

- (NSManagedObjectContext *)readOnlyContext
{
    return objc_getAssociatedObject(self, &kITReadOnlyContextKey);
}

- (void)setChangesContext:(NSManagedObjectContext *)changesContext
{
    objc_setAssociatedObject(self, &kITChangesContextKey, changesContext, OBJC_ASSOCIATION_RETAIN);
}

- (NSManagedObjectContext *)changesContext
{
    return objc_getAssociatedObject(self, &kITChangesContextKey);
}

@end
