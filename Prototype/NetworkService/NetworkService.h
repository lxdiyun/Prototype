//
//  NetworkService.h
//  Prototype
//
//  Created by Adrian Lee on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>

@interface NetworkService: NSObject
+ (void) requestSendMessage:(NSData *)message;
@end
