//
//  ITDatabaseOperationsQueue+Logging.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/11/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseOperationsQueue+Logging.h"

static ITLogLevel loggingLevel;

@implementation ITDatabaseOperationsQueue(Logging)

+ (void)setLogLevel:(ITLogLevel)logLevel
{
    if (logLevel != loggingLevel) {
        loggingLevel = logLevel;
    }
}

- (void)logMessage:(NSString *)message
{
    if ((loggingLevel & ITLogLevelMessages)) {
        [self logString:message];
    }
}

- (void)logWarning:(NSString *)warning
{
    if ((loggingLevel & ITLogLevelWarnings)) {
        [self logString:warning];
    }
}

- (void)logError:(NSError *)error
{
    if (!error) {
        return;
    }
    if ((loggingLevel & ITLogLevelErrors)) {
        [self logString:[NSString stringWithFormat:@"%@", error]];
    }
}

#pragma mark - Private

- (void)logString:(NSString*)string
{
    NSLog(@"ITDatabaseOperationsQueue log: %@", string);
}

@end
