//
//  FansListManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FansListManager.h"

#import "Util.h"

@implementation FansListManager

#pragma mark - singleton

DEFINE_SINGLETON(FansListManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (self)
	{
		@autoreleasepool 
		{
			self.getMethodString = @"friendship.get_fans";
		}
	}
	
	return self;
}


@end
