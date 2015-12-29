//
//  ITDatabaseManager.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ITManagedObjectContext;

@interface ITDatabaseManager : NSObject

@property (nonatomic, strong, readonly) ITManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readonly) ITManagedObjectContext *backgroundManagedObjectContext;

+ (NSURL *)applicationDocumentsDirectory;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType NS_DESIGNATED_INITIALIZER;

- (void)executeMainThreadOperation:(void (^)(NSManagedObjectContext *))mainThreadOperation;
- (void)executeBackgroundOperation:(void (^)(NSManagedObjectContext *))backgroundOperation;

@end
