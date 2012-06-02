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
@synthesize empty;

DEFINE_CUSTOM_XIB(NoticeHeader, 0);

#pragma mark - life circle

- (void)dealloc 
{
	[unread release];
    [empty release];
	[super dealloc];
}
@end
