//
//  Util.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

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


static CLLocationDistance distance_between_coordinate(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
	CLLocationDistance x = c1.longitude - c2.longitude;
	CLLocationDistance y = (c1.latitude - c2.latitude) * 2;

	return x * x + y * y;
}

NSInteger MAP_ANNOTATION_VIEW_SORTER(id view1, id view2, void *context)
{
	CLLocationCoordinate2D c1  = [[view1 annotation] coordinate];
	CLLocationCoordinate2D c2  = [[view2 annotation] coordinate];
	CLLocationCoordinate2D topLeft  = {90, -180};
	CLLocationDistance d1 = distance_between_coordinate(topLeft, c1);
	CLLocationDistance d2 = distance_between_coordinate(topLeft, c2);

	if (d1 < d2) 
	{
		return NSOrderedAscending;
	}

	return NSOrderedDescending;
}

void START_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];	
}

void STOP_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
}

void STOP_ALL_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] stopAllActivity];
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

	s_proportion = [UIScreen mainScreen].applicationFrame.size.width / 320.0;

	return s_proportion;
}

NSInteger DEVICE_TYPE(void)
{
	static NSInteger s_device_type = -1;

	if (-1 == s_device_type)
	{
		s_device_type = UI_USER_INTERFACE_IDIOM();
	}

	return s_device_type;
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

BOOL CHECK_EQUAL(id obj1, id obj2)
{
	if ((nil != obj1) && (nil != obj2))
	{
		return [obj1 isEqual:obj2];
	}
	else 
	{
		return obj1 == obj2;
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

void CONFIG_NAGIVATION_BAR(UINavigationBar *bar)
{
	bar.barStyle = UIBarStyleBlack;

	if([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) 
	{
		//iOS 5 new UINavigationBar custom background
		[bar setBackgroundImage:[UIImage imageNamed:@"DarkGrey.png"] forBarMetrics: UIBarMetricsDefault];
	} 
}

static UIButton * create_image_button(UIImage *image,id target, SEL action)
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)] autorelease];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

	return button;
}

static UIBarButtonItem * create_bar_button(UIImage *image,id target, SEL action)
{
	UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:SETUP_BUTTON(image, target, action)] autorelease];

	return item;
}

UIButton * SETUP_BUTTON(UIImage *image,id target, SEL action)
{
	UIButton *button = create_image_button(image, target, action);

	button.backgroundColor = [Color grey3Color];

	return button;
}

UIBarButtonItem * SETUP_BAR_BUTTON(UIImage *image,id target, SEL action)
{
	UIButton *button = SETUP_BUTTON(image, target, action);

	button.layer.cornerRadius = 5.0;

	return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

UIButton * SETUP_BACK_BUTTON(id target, SEL action)
{	
	UIButton *button = create_image_button([UIImage imageNamed:@"backArrow.png"], target, action);

	button.backgroundColor = [UIColor clearColor];

	return button;
}

UIBarButtonItem * SETUP_BACK_BAR_BUTTON(id target, SEL action)
{
	return [[[UIBarButtonItem alloc] initWithCustomView:SETUP_BACK_BUTTON(target, action)] autorelease];
}

UIButton * SETUP_TEXT_BUTTON(NSString *title, id target, SEL action)
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)] autorelease];
	[button.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[Color grey1Color] forState:UIControlStateHighlighted];
	[button setTitleColor:[Color darkgreyColor] forState:UIControlStateDisabled];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	button.backgroundColor = [Color grey3Color];
	button.layer.cornerRadius = 5.0;
	
	return button;
}
UIBarButtonItem * SETUP_BAR_TEXT_BUTTON(NSString *title, id target, SEL action)
{
	return [[[UIBarButtonItem alloc] initWithCustomView:SETUP_TEXT_BUTTON(title, target, action)] autorelease];
}

NSString * GET_STRING_FOR_SCORE(double score)
{
	if (score > 9.9)
	{
		return [NSString stringWithFormat:@"%d", (NSInteger)score];
	}
	else if (0 < ((NSInteger)(score * 10) % 10)) // if score has decimal
	{
		return [NSString stringWithFormat:@"%.1f", score];	
	}
	else if (0 <= score)
	{
		return [NSString stringWithFormat:@" %d ", (NSInteger)score];
	}
	else 
	{
		return @"－";
	}
}

NSString * GET_DESC_FOR_SCORE(double score)
{
	if (score == 10)
	{
		return @"完美之食";
	}
	else if (score >= 9)
	{
		return @"传奇美食";
	}
	else if (score >= 8)
	{
		return @"超乎寻常";
	}
	else if (score >= 7)
	{
		return @"尽足本份";
	}
	else if (score >= 6)
	{
		return @"颇有不足";
	}
	else if (score >= 5)
	{
		return @"可填肚";
	}
	else if (score >= 4)
	{
		return @"尽量不吃";
	}
	else if (score >= 3)
	{
		return @"饿都不吃";
	}
	else if (score >= 2)
	{
		return @"吃坏肚子";
	}
	else if (score >= 0)
	{
		return @"会吃死人";
	}
	else
	{
		return @"　";
	}
}

UIColor * GET_COLOR_FOR_SCORE(double score)
{
	if (score >= 8)
	{
		return [Color blueColor];
	}
	else 
	{
		return [Color grey2Color];
	}
}


