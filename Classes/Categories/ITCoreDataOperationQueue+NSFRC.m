//
//  ITCoreDataOperationQueue+NSFRC.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue+NSFRC.h"
#import "ITCoreDataOperationQueue+Private.h"
#import "ITCoreDataOperationQueue+Logging.h"

@implementation ITCoreDataOperationQueue(NSFRC)

- (NSFetchedResultsController *)newControllerWithRequest:(NSFetchRequest *)request
                                   sectionKeyPathName:(NSString *)keyPath
                                             delegate:(id <NSFetchedResultsControllerDelegate>)delegate
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

- (NSFetchedResultsController *)newControllerWithRequest:(NSFetchRequest *)request
                                         andDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
{
    return [self newControllerWithRequest:request sectionKeyPathName:nil delegate:delegate];
}

@end
