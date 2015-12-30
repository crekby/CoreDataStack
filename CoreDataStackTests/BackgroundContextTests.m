//
//  BackgroundContextTests.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestEntity.h"
#import "CoreDataStackTestCase.h"

static NSString *kITTestEntityName = @"TestEntity";

@interface BackgroundContextTests : CoreDataStackTestCase

@end

@implementation BackgroundContextTests

- (void)testThatBackroundContextReturnObjectInMainContext
{
    XCTestExpectation* expectation = [self expectationWithDescription:@"Wait expectation"];
    [self.databaseManager executeBackgroundOperation:^NSArray *(NSManagedObjectContext *context) {
        TestEntity *object = [TestEntity insertObjectInManagedObjectContext:context];
        return @[object];
    } mainThreadOperation:^(NSError *error, NSArray *result) {
        XCTAssertNil(error);
        TestEntity *object = result.firstObject;
        XCTAssertNotNil(object);
        XCTAssert(object.managedObjectContext.concurrencyType == NSMainQueueConcurrencyType, @"returned object is not in main context");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
