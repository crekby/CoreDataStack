//
//  ITCoreDataOperationQueue+Private.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue.h"
#import "ITCoreDataOperationQueue+Logging.h"

@interface ITCoreDataOperationQueue(Private)

@property (nonatomic, strong, readonly) NSManagedObjectModel *model;
@property (nonatomic, strong, readonly) NSManagedObjectContext *readOnlyContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *changesContext;
@property (nonatomic, assign) ITLogLevel loggingLevel;

@end
