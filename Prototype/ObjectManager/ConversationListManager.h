//
//  ConversationListManager.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface ConversationListManager : ListObjectManager
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) keyArray;
+ (BOOL) isNewerUpdating;
+ (NSDate *) lastUpdatedDate;
+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID;
@end
