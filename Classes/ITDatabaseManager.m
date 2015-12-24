//
//  ITDatabaseManager.m
//  CoreDataStack
//
//  Created by Aliaksandr Skulin on 12/24/15.
//  Copyright © 2015 Aliaksandr Skulin. All rights reserved.
//

#import "ITDatabaseManager.h"

@interface ITDatabaseManager()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSString *storeType;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation ITDatabaseManager

- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType
{
    NSParameterAssert(model);
    NSParameterAssert(storeName);
    NSParameterAssert(storeType);
    
    self = [super init];
    if (self) {
        _model = model;
        _storeType = storeType;
        _storeURL = [[ITDatabaseManager applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
