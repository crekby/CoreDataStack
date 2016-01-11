//
//  ITDatabaseOperationsQueue+Clear.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue+Clear.h"
#import "ITDatabaseOperationsQueue+Private.h"
#import "ITDatabaseOperationsQueue+Logging.h"

@implementation ITDatabaseOperationsQueue(Clear)

- (void)clearAllEntitiesWithCompletion:(void (^)(NSError *))completion
{
    [self.changesContext performBlock:^{
        NSArray *allEntities = self.model.entities;
        
        [allEntities enumerateObjectsUsingBlock:^(NSEntityDescription *entityDescription, NSUInteger idx, BOOL *stop) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityDescription.name];
            NSError *error;
            NSArray *results = [self.changesContext executeFetchRequest:request error:&error];
            [self logError:error];
            if (!error) {
                for (NSManagedObject *object in results) {
                    [self.changesContext deleteObject:object];
                }
            }
        }];
        NSError *error;
        [self.changesContext save:&error];
        [self logError:error];
        if (completion) {
            completion(error);
        }
    }];
}

@end
