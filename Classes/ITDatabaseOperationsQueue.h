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
@interface ITDatabaseOperationsQueue : NSObject

/**
 URL to Documents directory in application sandbox.
 */
+ (NSURL *)applicationDocumentsDirectory;

#pragma mark - Inits

/**
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns initialised database operations queue with given contexts and model. If you don't want to initialise contexts by yourself, you can use method initWithModel:storeName:storeType: declared in Init category
 @param model core data model
 @param context context with allowed changes
 @param readOnlyContext context only for read only operations
 */
- (instancetype)initWithModel:(NSManagedObjectModel*)model managedObjectContext:(NSManagedObjectContext*)context readOnlyManagedObjectContext:(NSManagedObjectContext*)readOnlyContext NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods

/**
 Executes given block in read only context.
 @warning DO NOT USE READ ONLY CONTEXT FOR CHANGES, USE IT ONLY FOR FETCHING.
 @param backgroundOperation Block for execution.
 */
- (void)executeReadOnlyOperation:(void (^)(NSManagedObjectContext *context))mainThreadOperation;

/**
 Executes given block in background.
 @warning USE BACKGROUND CONTEXT FOR MAKING CHANGES IN YOUR MODEL, NOT MAIN CONTEXT.
 @param backgroundOperation Block for execution.
 */
- (void)executeOperation:(void (^)(NSManagedObjectContext *context))backgroundOperation;

/**
 Executes given blocks in background and in read only contexts respectively. Background block should return fetched data or nil.
 @param backgroundOperation Block for background context execution, use it to fetching and changing your data. return your results from this block.
 @param mainThreadOperation Block for mainThread context execution, result from backgroun operation sending to this block from main context.
 */
- (void)executeOperation:(BackroundOperationWithResultBlock)backgroundOperation
               readOnlyOperation:(MainThreadOperationWithResultBlock)mainThreadOperation;

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

/**
 Clear All entities from database in background context.
*/
- (void)clearAllEntities;

/**
 Clear All entities from database in background context and wait until operation complete.
 */
- (void)clearAllEntitiesAndWait;


@end

