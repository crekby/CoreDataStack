//
//  NSManagedObject+ChangeAssert.m
//  Pods
//
//  Created by Aliaksandr Skulin on 12/28/15.
//
//

#import "NSManagedObject+ChangeAssert.h"

@implementation NSManagedObject(ChangeAssert)

- (void)willChangeValueForKey:(NSString *)key
{
    [super willChangeValueForKey:key];
    NSAssert(NO, @"Changing objects in main context is not allowed. Please use Background context.");
}

@end
