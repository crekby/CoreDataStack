//
//  ITCoreDataOperationQueue+NSFRC.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue.h"

@interface ITCoreDataOperationQueue(NSFRC)

/**
 Returns fetch result controller with given properties. Executes in main context.
 @param request The fetch request used to get the objects..
 @param delegate delegate for fetch result controller.
 */
- (NSFetchedResultsController *)newControllerWithRequest:(NSFetchRequest *)request
                                         andDelegate:(id <NSFetchedResultsControllerDelegate>)delegate;

/**
 Returns fetch result controller with given properties. Executes in main context.
 @param request The fetch request used to get the objects..
 @param keyPath A key path on result objects that returns the section name. Pass nil to indicate that the controller should generate a single section.
 @param delegate delegate for fetch result controller.
 */
- (NSFetchedResultsController *)newControllerWithRequest:(NSFetchRequest *)request
                                   sectionKeyPathName:(NSString *)keyPath
                                             delegate:(id <NSFetchedResultsControllerDelegate>)delegate;

@end
