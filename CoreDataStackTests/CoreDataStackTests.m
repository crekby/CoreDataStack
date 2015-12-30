//
//  CoreDataStackTests.m
//  CoreDataStackTests
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "ITDatabaseManager.h"
#import "TestEntity.h"

@interface CoreDataStackTests : XCTestCase

@property (nonatomic, strong) ITDatabaseManager *databaseManager;

@end

@implementation CoreDataStackTests

- (void)setUp {
    [super setUp];
    NSString *storeName = NSStringFromSelector([self.invocation selector]);
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"TestModel" withExtension:@"momd"];
    self.databaseManager = [[ITDatabaseManager alloc] initWithModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] storeName:storeName storeType:NSInMemoryStoreType];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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
