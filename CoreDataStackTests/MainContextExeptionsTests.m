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

static NSString *kITTestEntityName = @"TestEntity";
static NSString *kITChangesExceptionMessage = @"Changes in main context is not allowed. Please use background context.";

@implementation MainContextExeptionsTests

- (void)testThatInsertObjectInMainContextWillTrowExeption
{
    XCTAssertThrowsSpecific([NSEntityDescription insertNewObjectForEntityForName:kITTestEntityName inManagedObjectContext:self.databaseManager.mainManagedObjectContext], NSException, @"%@", kITChangesExceptionMessage);
}

- (void)testThatDeletingObjectFromMainContextWillTrowExeption
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait expectation"];
    [self.databaseManager executeBackgroundOperation:^NSArray *(NSManagedObjectContext *context) {
        TestEntity *object = [TestEntity insertObjectInManagedObjectContext:context];
        return @[object];
    } mainThreadOperation:^(NSError *error, NSArray *result) {
        TestEntity *object = result.firstObject;
        XCTAssertThrowsSpecific([self.databaseManager.mainManagedObjectContext deleteObject:object], NSException, @"%@", kITChangesExceptionMessage);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testThatMainContextSaveThrowsException
{
    [self.databaseManager executeMainThreadOperation:^(NSManagedObjectContext *context) {
        XCTAssertThrowsSpecific([context save:nil], NSException, @"%@", kITChangesExceptionMessage);
    }];
}

@end
