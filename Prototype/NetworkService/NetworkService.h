//
//  NetworkService.h
//  Prototype
//
//  Created by Adrian Lee on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>


@interface NetworkService : NSObject 
{
	
}
+ (NetworkService*) getInstance;
- (void)requestsendAndHandleMessage:(NSData *)message withTarget:(id)target withHandler:(SEL)hanlder withMessageID:(uint32_t)ID;
@end
