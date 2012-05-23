//
//  NoticeHeader.m
//  Prototype
//
//  Created by Adrian Lee on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoticeHeader.h"

@implementation NoticeHeader

#pragma mark - custom xib object
@synthesize unread;

DEFINE_CUSTOM_XIB(NoticeHeader);

#pragma mark - life circle

- (void)dealloc 
{
	[unread release];
	[super dealloc];
}
@end
