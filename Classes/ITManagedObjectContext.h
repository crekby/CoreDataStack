//
//  ITManagedObjectContext.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/28/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 @warning DO NOT SUBCLASS FROM THIS CLASS. IT'S ONLY FOR FORBBIDING CHANGES IN MAIN THREAD CONTEXT.
 */

@interface ITManagedObjectContext : NSManagedObjectContext

@end
