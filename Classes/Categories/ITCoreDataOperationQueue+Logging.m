//
//  ITCoreDataOperationQueue+Logging.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITCoreDataOperationQueue+Logging.h"
#import "ITCoreDataOperationQueue+Private.h"

@implementation ITCoreDataOperationQueue(Logging)

- (void)setLogLevel:(ITLogLevel)logLevel
{
    if (logLevel != self.loggingLevel) {
        self.loggingLevel = logLevel;
    }
}

- (void)logMessage:(NSString *)message
{
    if ((self.loggingLevel & ITLogLevelMessages)) {
        [self logString:message];
    }
}

- (void)logWarning:(NSString *)warning
{
    if ((self.loggingLevel & ITLogLevelWarnings)) {
        [self logString:warning];
    }
}

- (void)logError:(NSError *)error
{
    if (!error) {
        return;
    }
    if ((self.loggingLevel & ITLogLevelErrors)) {
        [self logString:[NSString stringWithFormat:@"%@", error]];
    }
}

#pragma mark - Private

- (void)logString:(NSString*)string
{
    printf("[ITCoreDataOperationQueue]: %s", [string UTF8String]);
}

@end
