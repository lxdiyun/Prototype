//
//  FollowingListManager.h
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendShipManager.h"

@interface FollowingListManager : FriendShipManager

+ (void) unFollow:(NSNumber *)userID with:(SEL)handler and:(id)target;
+ (void) follow:(NSNumber *)userID with:(SEL)handler and:(id)target;

@end
