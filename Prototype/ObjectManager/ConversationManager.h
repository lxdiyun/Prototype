//
//  ConversationManager.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface ConversationManager : ListObjectManager

+ (void) senMessage:(NSString *)message 
	     toUser:(NSString *)listID 
	withHandler:(SEL)handler 
	  andTarget:target;
+ (BOOL) hasNewMessageForUser:(NSString *)userID;
+ (void) setHasNewMessage:(BOOL)flag forUser:(NSString *)userID;
@end
