//
//  NSManagedObject+Additions.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject(Additions)

+(nullable __kindof NSManagedObject *) insertObjectInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                            inManagedObjectContext:context];
    return object;
}

@end

