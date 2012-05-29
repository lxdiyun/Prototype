//
//  MessageHeader.m
//  Prototype
//
//  Created by Adrian Lee on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageHeader.h"

@implementation MessageHeader

#pragma mark - custom xib object
@synthesize unread;
@synthesize empty;

DEFINE_CUSTOM_XIB(MessageHeader);

#pragma mark - life circle

- (void)dealloc 
{
	[unread release];
	[empty release];
	[super dealloc];
}
@end
