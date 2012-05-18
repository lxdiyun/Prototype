//
//  UserFoodHistoryMananger.m
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserFoodHistoryManager.h"

#import "Util.h"

@implementation UserFoodHistoryManager

#pragma mark - singleton

DEFINE_SINGLETON(UserFoodHistoryManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (self)
	{
		@autoreleasepool 
		{
			self.getMethodString = @"food.get_share_list";
		}
	}
	
	return self;
}

@end
