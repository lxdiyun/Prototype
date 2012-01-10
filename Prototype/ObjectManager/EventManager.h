//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ListObjectManager.h"

@interface EventManager : ListObjectManager
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) eventKeyArray;
+ (BOOL) isNewerUpdating;
+ (NSDate *) lastUpdatedDate;
+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID;
@end
