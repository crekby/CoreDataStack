//
//  NSManagedObject+Additions.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject(Additions)

+(nullable NSManagedObject *) insertObjectInManagedObjectContext:(nonnull NSManagedObjectContext *)context;

@end

