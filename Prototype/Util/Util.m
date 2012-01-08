//
//  Util.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import "SDNetworkActivityIndicator.h"
#import "Message.h"

static NSNumber *gs_login_user_id = nil;

NSNumber * GET_USER_ID(void)
{
	return gs_login_user_id;
}

void SET_USER_ID(NSNumber *ID)
{
	if (gs_login_user_id == ID)
	{
		return;
	}
	[gs_login_user_id release];
	gs_login_user_id = [ID retain];
}

NSInteger ID_SORTER(id ID1, id ID2, void *context)
{
	uint32_t v1 = [ID1 integerValue];
	uint32_t v2 = [ID2 integerValue];
	if (v1 > v2)
		return NSOrderedAscending;
	else if (v1 < v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

uint32_t SEND_MSG_AND_BIND_HANDLER(NSDictionary *messageDict, id target, SEL handler)
{
	return SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(messageDict, target, handler, NORMAL_PRIORITY);
}

void START_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
}

void STOP_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
}

CGFloat GET_SCALE(void)
{
	static CGFloat s_sclae = 0;
	
	if (0.1 >= s_sclae)
	{
	
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		{
			s_sclae = [[UIScreen mainScreen] scale];
		}
		else
		{
			s_sclae = 1.0;
		}
	}
	
	return s_sclae;
}

CGFloat GET_PROPORTION(void)
{
	static CGFloat s_proportion = 0;
	
	if (0.1 >= s_proportion)
	{
		s_proportion = [UIScreen mainScreen].applicationFrame.size.width / 320;
	}
	
	return s_proportion;
}

@implementation Color

+ (UIColor *) greyColor
{
	return [UIColor colorWithRed:0xEE/255.0 green:0xEE/255.0 blue:0xEE/255.0 alpha:1.0];
}

+ (UIColor *) brownColor
{
	return [UIColor colorWithRed:0x40/255.0 green:0x24/255.0 blue:0x1A/255.0 alpha:1.0];
}

+ (UIColor *) blackColorAlpha
{
	return [UIColor colorWithRed:0x0/255.0 green:0x0/255.0 blue:0x0/255.0 alpha:0.5];
}

@end
