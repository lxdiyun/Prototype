//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ListObjectManager.h"
#import "Task.h"

static NSString *EVENT_TASK_ID_PREFIX = @"TaskEvent";

@interface EventManager : ListObjectManager
+ (void) requestNewestCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSInteger) keyCount;
+ (NSArray *) keyArray;
+ (BOOL) isNewestUpdating;
+ (BOOL) isNewerUpdating;
+ (NSDate *) lastUpdatedDate;
+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID;
+ (void) removeEventsForUser:(NSNumber *)userID;
+ (void) removeEventByFood:(NSNumber *)foodID;
+ (void) addTaskEvent:(NSMutableDictionary *)event with:(Task *)task;
+ (void) removeTaskEvent:(Task *)task;
@end
