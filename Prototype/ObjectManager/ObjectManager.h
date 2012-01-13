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
@property (strong) NSMutableDictionary *responderArrayDict;
@property (strong) NSMutableDictionary *updatingDict;
// get object
+ (NSDictionary *) getObjectWithStringID:(NSString *)ID;
+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID;
// request object
// bind object handler
+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target;
+ (void) bindNumberID:(NSNumber *)ID withHandler:(SEL)handler andTarget:(id)target;
// send object request
+ (void) sendObjectRequest:(NSDictionary *)request withNumberID:(NSNumber *) ID;
+ (void) sendObjectArrayRequest:(NSDictionary *)request withNumberIDArray:(NSArray *)IDArray;
// request get object
+ (void) requestObjectWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
+ (void) requestObjectWithNumberIDArray:(NSArray *)numberIDArray;
// mark object updating
+ (void) markUpdatingStringID:(NSString *)ID;
+ (void) markUpdatingNumberID:(NSNumber *)ID;
+ (void) cleanUpdatingStringID:(NSString *)ID;
+ (void) cleanUpdatingNumberID:(NSNumber *)ID;
+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray;
+ (BOOL) isUpdatingObjectStringID:(NSString *)ID;
+ (BOOL) isUpdatingObjectNumberID:(NSNumber *)ID;

// method that must be overwrite by sub class
+ (NSString *) getMethod;
// method that can be overwrite by sub class
// handler
- (void) checkAndPerformResponderWithID:(NSString *)ID;
- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray;
@end
