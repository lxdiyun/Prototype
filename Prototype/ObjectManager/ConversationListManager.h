//
//  ConversationListManager.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface ConversationListManager : ListObjectManager
+ (void) requestNewestCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) keyArray;
+ (BOOL) isNewestUpdating;
+ (NSDate *) lastUpdatedDate;
+ (NSDictionary *) getConversationWith:(NSString *)ID;
+ (void) checkNew;
@end
