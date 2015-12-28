//
//  ITManagedObjectContext.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/28/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ITManagedObjectContext : NSManagedObjectContext

@property (nonatomic, assign) BOOL forbidChanges;

@end
