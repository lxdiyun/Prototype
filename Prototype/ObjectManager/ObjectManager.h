//
//  ObjectManager.h
//  Prototype
//
//  Created by Adrian Lee on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectManager : NSObject
@property (strong) NSMutableDictionary *objectDict;
@property (strong) NSMutableDictionary *responderDictForGet;
@property (strong) NSMutableDictionary *responderDictForCreate;
@property (strong) NSMutableDictionary *updatingDict;
@property (strong) NSDictionary *createParams;
@property (strong) NSDictionary *updateParams;

// save and restore
+ (void) saveTo:(NSMutableDictionary *)dict;
+ (void) restoreFrom:(NSMutableDictionary *)dict;

// object updating flagss
+ (void) markUpdatingStringID:(NSString *)ID;
+ (void) markUpdatingNumberID:(NSNumber *)ID;
+ (void) cleanUpdatingStringID:(NSString *)ID;
+ (void) cleanUpdatingNumberID:(NSNumber *)ID;
+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray;
+ (BOOL) isUpdatingObjectStringID:(NSString *)ID;
+ (BOOL) isUpdatingObjectNumberID:(NSNumber *)ID;

// get object
+ (NSDictionary *) getObjectWithStringID:(NSString *)ID;
+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID;

// set object
+ (void) setObject:(NSDictionary *)object withStringID:(NSString *)ID;
+ (void) setObject:(NSDictionary *)object withNumberID:(NSNumber *)ID;

// get method
// internal handler
- (void) checkAndPerformResponderWithID:(NSString *)ID;
- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray;
// bind object handler
+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target;
+ (void) bindNumberID:(NSNumber *)ID withHandler:(SEL)handler andTarget:(id)target;
// request get object
+ (void) requestObjectWithStringID:(NSString *)ID andHandler:(SEL)handler andTarget:(id)target;
+ (void) requestObjectWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
+ (void) requestObjectWithNumberIDArray:(NSArray *)numberIDArray;

// create method
// internal handler
- (void) handlerForCreate:(id)result;
// request create object
+ (NSInteger) createObjectWithHandler:(SEL)handler andTarget:(id)target;

// update method
- (void) handlerForUpate:(id)result;
// request update object
+ (NSInteger) updateObjectWithhandler:(SEL)handler andTarget:(id)target;


// functions that must be overwrite by sub class if you want to use that method
// get method
- (NSString *) getMethod;
// create method
- (NSString *) createMethod;
// update method
- (NSString *) updateMethod;

@end
