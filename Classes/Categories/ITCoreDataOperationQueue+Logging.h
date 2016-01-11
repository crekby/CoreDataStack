//
//  ITCoreDataOperationQueue+Logging.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue.h"

typedef NS_OPTIONS(NSUInteger, ITLogLevel) {
    ITLogLevelOff = 0,
    ITLogLevelMessages = 1 << 1,
    ITLogLevelWarnings = 1 << 2,
    ITLogLevelErrors = 1 << 3,
    ITLogLevelAll = ITLogLevelMessages | ITLogLevelWarnings | ITLogLevelErrors
};

@interface ITCoreDataOperationQueue(Logging)

@property (nonatomic, assign) ITLogLevel loggingLevel;

- (void)setLogLevel:(ITLogLevel)logLevel;

- (void)logMessage:(NSString*)message;

- (void)logWarning:(NSString*)warning;

- (void)logError:(NSError*)error;

@end
