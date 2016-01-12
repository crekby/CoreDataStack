//
//  CoreDataStackTestCase.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataStack.h"
#import <CoreData/CoreData.h>
#import "TestEntity.h"

@class ITCoreDataOperationQueue;

@interface CoreDataStackTestCase : XCTestCase

@property (nonatomic, strong) ITCoreDataOperationQueue *databaseQueue;

@end
