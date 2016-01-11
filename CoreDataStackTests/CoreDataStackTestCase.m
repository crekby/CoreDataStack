//
//  CoreDataStackTestCase.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "CoreDataStackTestCase.h"

@implementation CoreDataStackTestCase

- (void)setUp {
    [super setUp];
    NSString *storeName = NSStringFromSelector([self.invocation selector]);
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"TestModel" withExtension:@"momd"];
    self.databaseQueue = [[ITDatabaseOperationsQueue alloc] initWithModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] storeName:storeName storeType:NSInMemoryStoreType];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
