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

NSInteger ID_SORTER_REVERSE(id ID1, id ID2, void *context)
{
	uint32_t v1 = [ID1 integerValue];
	uint32_t v2 = [ID2 integerValue];
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

void START_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
}

void STOP_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
}

CGFloat SCALE(void)
{
	CGFloat sclae = 0;

	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		sclae = [[UIScreen mainScreen] scale];
	}
	else
	{
		sclae = 1.0;
	}
	
	return sclae;
}

CGFloat PROPORTION(void)
{
	static CGFloat s_proportion = 0;
	
	if (0.1 >= s_proportion)
	{
		s_proportion = [UIScreen mainScreen].applicationFrame.size.width / 320;
	}
	
	return s_proportion;
}

// check and error handling;
BOOL CHECK_NUMBER(NSNumber *object)
{
	if ((nil != object) && [object isKindOfClass:[NSNumber class]])
	{
		return YES;
	}
	else
	{
		CLOG(@"Error object is not an NUMBER: %@", object);
		return NO;
	}
}

// alert
BOOL CHECK_STRING(NSString *object)
{
	if ((nil != object) && [object isKindOfClass:[NSString class]])
	{
		return YES;
	}
	else
	{
		CLOG(@"Error object is not an STRING: %@", object);
		return NO;
	}
}

void SHOW_ALERT_TEXT(NSString *title, NSString *message)
{
	UIAlertView *alert = [[UIAlertView alloc]  init];
	
	alert.title = title;
	alert.message = message;
	[alert addButtonWithTitle:@"OK"];

	[alert show];
	[alert release]; 
}

@implementation Color

+ (UIColor *) tastyColor
{
	return [UIColor colorWithRed:0x21/255.0 green:0xA6/255.0 blue:0xCE/255.0 alpha:1.0];
}

+ (UIColor *) specailColor
{
	return [UIColor colorWithRed:0xDD/255.0 green:0x4B/255.0 blue:0x39/255.0 alpha:1.0];
}

+ (UIColor *) valuedColor
{
	return [UIColor colorWithRed:0xFB/255.0 green:0xB0/255.0 blue:0x3B/255.0 alpha:1.0];
}

+ (UIColor *) healthyColor
{
	return [UIColor colorWithRed:0x6A/255.0 green:0xC6/255.0 blue:0x00/255.0 alpha:1.0];
}

+ (UIColor *) whiteColor 
{
	return [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:1.0];
}

+ (UIColor *) milkColor
{
	return [UIColor colorWithRed:0xE6/255.0 green:0xE6/255.0 blue:0xE6/255.0 alpha:1.0];
}

+ (UIColor *) orangeColor
{
	return [UIColor colorWithRed:0xD3/255.0 green:0x8E/255.0 blue:0x33/255.0 alpha:1.0];
}

+ (UIColor *) grey1Color
{
	return [UIColor colorWithRed:0xEE/255.0 green:0xEE/255.0 blue:0xEE/255.0 alpha:1.0];
}

+ (UIColor *) grey2Color
{
	return [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
}

+ (UIColor *) grey3Color
{
	return [UIColor colorWithRed:0xAA/255.0 green:0xAA/255.0 blue:0xAA/255.0 alpha:1.0];
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
