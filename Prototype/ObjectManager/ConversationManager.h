//
//  ConversationManager.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface ConversationManager : ListObjectManager

+ (void) createConversation:(NSString *)message 
		    forList:(NSString *)listID 
		withHandler:(SEL)handler 
		  andTarget:target;

@end
