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

/**
 Block for executing from background context.
 @param context background context.
 @return fetch result array or nil.
 */
typedef NSArray*(^BackroundOperationWithResultBlock)(NSManagedObjectContext *context);

/**
 Block for executing from main context.
 @param error error which appear during background context save, or during main context result fetching.
 @param result result array from background context, suitable for using in main thread.
 */
typedef void(^MainThreadOperationWithResultBlock)(NSError *error, NSArray *result);


/**
 Database manager class for managing core data operations for 2 NSManagedObjectContexts, one is for main thread, and other is for background.
 You only allowed to make changes to your data in background context.
 Main context is only for fetching data and use it for UI related manipulation.
 Both contexts have same persistence store coordinator.
 And after saving changes in background context, they are merged to main context.
 */
@interface ITDatabaseManager : NSObject

/**
 NSManagedObjectContext for main thread.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;

/**
 NSManagedObjectContext for background thread.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

/**
 URL to Documents directory in application sandbox.
 */
+ (NSURL *)applicationDocumentsDirectory;

/**
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns Database manager instance with given parametrs.
 @param model Model object.
 @param storeName Name for store on file system.
 @param storeType Store type (NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType).
 */
- (instancetype)initWithModel:(NSManagedObjectModel *)model storeName:(NSString *)storeName storeType:(NSString *)storeType NS_DESIGNATED_INITIALIZER;

/**
 Executes given block in main trhead. 
 @warning DO NOT USE MAIN THREAD CONTEXT FOR CHANGES, USE IT ONLY FOR FETCHING.
 @param backgroundOperation Block for execution.
 */
- (void)executeMainThreadOperation:(void (^)(NSManagedObjectContext *context))mainThreadOperation;

/**
 Executes given block in background.
 @warning USE BACKGROUND CONTEXT FOR MAKING CHANGES IN YOUR MODEL, NOT MAIN CONTEXT.
 @param backgroundOperation Block for execution.
 */
- (void)executeBackgroundOperation:(void (^)(NSManagedObjectContext *context))backgroundOperation;

/**
 Executes given blocks in background and in main context respectively. Background block should return fetched data or nil.
 @param backgroundOperation Block for background context execution, use it to fetching and changing your data. return your results from this block.
 @param mainThreadOperation Block for mainThread context execution, result from backgroun operation sending to this block from main context.
 */
- (void)executeBackgroundOperation:(BackroundOperationWithResultBlock)backgroundOperation
               mainThreadOperation:(MainThreadOperationWithResultBlock)mainThreadOperation;

/**
 Returns fetch result controller with given properties. Executes in main context.
 @param request The fetch request used to get the objects..
 @param delegate delegate for fetch result controller.
 */
- (NSFetchedResultsController*)controllerWithRequest:(NSFetchRequest *)request
                                         andDelegate:(id <NSFetchedResultsControllerDelegate>)delegate;

/**
 Returns fetch result controller with given properties. Executes in main context.
 @param request The fetch request used to get the objects..
 @param keyPath A key path on result objects that returns the section name. Pass nil to indicate that the controller should generate a single section.
 @param delegate delegate for fetch result controller.
 */
- (NSFetchedResultsController *)controllerWithRequest:(NSFetchRequest *)request
                                   sectionKeyPathName:(NSString *)keyPath
                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

@end
