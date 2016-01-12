//
//  FetchResultControllerTests.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 1/12/16.
//  Copyright © 2016 Aliaksandr Skulin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataStackTestCase.h"

@interface FetchResultControllerTests : CoreDataStackTestCase <NSFetchedResultsControllerDelegate>

@end

@implementation FetchResultControllerTests

- (void)testThatITCoreDataOperationQueueReturnConfiguredNSFRC
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"TestEntity"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"testProperty" ascending:YES]];
    NSFetchedResultsController *controller = [self.databaseQueue newControllerWithRequest:request andDelegate:self];
    XCTAssertNotNil(controller);
    XCTAssert([controller.fetchRequest isEqual:request]);
    XCTAssert([controller.delegate isEqual:self]);
}

@end
