//
//  NotificationManager.h
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface NotificationManager : ListObjectManager

+ (void) requestNewestCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) keyArray;
+ (BOOL) isNewestUpdating;
+ (NSDate *) lastUpdatedDate;
+ (NSDictionary *) getNotificationWith:(NSString *)ID;

@end
