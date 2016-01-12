//
//  ClearAllEntitiesTests.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/12/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataStackTestCase.h"

@interface ClearAllEntitiesTests : CoreDataStackTestCase

@end

@implementation ClearAllEntitiesTests

- (void)testThatAllEntitiesDeliting
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"first expectation"];
    [self.databaseQueue executeOperation:^NSArray *(NSManagedObjectContext *context) {
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i < 10; i++) {
            [array addObject:[TestEntity insertObjectInManagedObjectContext:context]];
        }
        return array;
    } mainThreadOperation:^(NSError *error, NSArray *result) {
        XCTAssert(result.count == 10);
        [self.databaseQueue clearAllEntitiesWithCompletion:^(NSError *error) {
            XCTAssertNil(error);
            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTestExpectation *secondExpectation = [self expectationWithDescription:@"second expectation"];
    [self.databaseQueue executeOperation:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TestEntity"];
        NSArray* result = [context executeFetchRequest:request error:nil];
        XCTAssert(result.count == 0);
        [secondExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
