//
//  TestEntity+CoreDataProperties.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/30/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *testProperty;

@end

NS_ASSUME_NONNULL_END
