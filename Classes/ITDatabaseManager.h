//
//  ITDatabaseManager.h
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITDatabaseManager : NSObject

+ (NSURL *)applicationDocumentsDirectory;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType NS_DESIGNATED_INITIALIZER;

@end
