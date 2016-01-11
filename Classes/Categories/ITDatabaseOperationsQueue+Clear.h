//
//  ITDatabaseOperationsQueue+Clear.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue.h"

@interface ITDatabaseOperationsQueue(Clear)

/**
 Clear All entities from database in background context.
 */
- (void)clearAllEntitiesWithCompletion:(void (^)(NSError *error))completion;


@end
