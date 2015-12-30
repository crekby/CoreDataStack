//
//  MainContextExeptionsTests.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "CoreDataStackTestCase.h"
#import "TestEntity.h"

@interface MainContextExeptionsTests : CoreDataStackTestCase

@end

@implementation MainContextExeptionsTests

- (void)testThatInsertObjectInMainContextWillTrowExeption
{
    XCTAssertThrowsSpecific([NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:self.databaseManager.mainManagedObjectContext], NSException, @"Changes in main context is not allowed. Please use background context.");
}

- (void)testThatDeletingObjectFromMainContextWillTrowExeption
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait expectation"];
    [self.databaseManager executeBackgroundOperation:^NSArray *(NSManagedObjectContext *context) {
        TestEntity *object = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:self.databaseManager.backgroundManagedObjectContext];
        return @[object];
    } mainThreadOperation:^(NSError *error, NSArray *result) {
        TestEntity *object = result.firstObject;
        XCTAssertThrowsSpecific([self.databaseManager.mainManagedObjectContext deleteObject:object], NSException, @"Changes in main context is not allowed. Please use background context.");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testThatChangingObjectInMainContextWillTrowExeption
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait expectation"];
    [self.databaseManager executeBackgroundOperation:^NSArray *(NSManagedObjectContext *context) {
        TestEntity *object = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:self.databaseManager.backgroundManagedObjectContext];
        return @[object];
    } mainThreadOperation:^(NSError *error, NSArray *result) {
        TestEntity *object = result.firstObject;
        XCTAssertThrowsSpecific([object setValue:@"1" forKey:@"testProperty"], NSException, @"Changes in main context is not allowed. Please use background context.");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
