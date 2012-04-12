//
//  CommentManager.h
//  Prototype
//
//  Created by Adrian Lee on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface CommentManager : ListObjectManager

@property (strong) NSString *objectTypeString;

+ (void) createComment:(NSString *)text 
	       forList:(NSString *)listID 
	   withHandler:(SEL)handler 
	     andTarget:target;

@end
