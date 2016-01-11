//
//  ITDatabaseOperationsQueue+NSFRC.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue+NSFRC.h"
#import "ITDatabaseOperationsQueue+Private.h"
#import "ITDatabaseOperationsQueue+Logging.h"

@implementation ITDatabaseOperationsQueue(NSFRC)

- (NSFetchedResultsController *)controllerWithRequest:(NSFetchRequest *)request
                                   sectionKeyPathName:(NSString *)keyPath
                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    NSAssert([request.sortDescriptors count] > 0, @"NSFetchedResultController requres sort descriptors.");
    NSAssert(request.resultType == NSManagedObjectResultType, @"NSFetchedResultController requires NSManagedObject Result Type");
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:self.readOnlyContext
                                                                                   sectionNameKeyPath:keyPath
                                                                                            cacheName:nil];
    controller.delegate = delegate;
    NSError *error;
    if (![controller performFetch:&error]) {
        [self logError:error];
        return nil;
    }
    return controller;
}

- (NSFetchedResultsController*)controllerWithRequest:(NSFetchRequest *)request
                                         andDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
{
    return [self controllerWithRequest:request sectionKeyPathName:nil delegate:delegate];
}

@end
