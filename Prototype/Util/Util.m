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
#import "FoodPage.h"
#import "MapViewPage.h"

// util

void SWAP(id *ID1, id *ID2)
{
	id temp = *ID1;
	
	*ID1 = *ID2;
	*ID2 = temp;
}

// login user id

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

// sorter
NSInteger ID_SORTER(id ID1, id ID2, void *context)
{
	NSUInteger v1 = [ID1 integerValue];
	NSUInteger v2 = [ID2 integerValue];

	if (v1 > v2)
		return NSOrderedAscending;
	else if (v1 < v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}
NSInteger ID_SORTER_REVERSE(id ID1, id ID2, void *context)
{
	NSUInteger v1 = [ID1 integerValue];
	NSUInteger v2 = [ID2 integerValue];

	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

NSInteger LIST_RESULT_SORTER(id ID1, id ID2, void *context)
{
	if ([(id)context isKindOfClass:[NSDictionary class]])
	{
		NSUInteger v1 = [[(NSDictionary *)context valueForKey:ID1] integerValue];
		NSUInteger v2 = [[(NSDictionary *)context valueForKey:ID2] integerValue];
		
		if (v1 > v2)
			return NSOrderedAscending;
		else if (v1 < v2)
			return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

NSInteger NOTIFICATION_SORTER(id ID1, id ID2, void *context)
{
	if ([(id)context isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *noticfication1 = [(NSDictionary *)context valueForKey:ID1];
		NSDictionary *noticfication2 = [(NSDictionary *)context valueForKey:ID2];
		BOOL n1Readed = [[noticfication1 valueForKey:@"is_read"] boolValue];
		BOOL n2Readed = [[noticfication2 valueForKey:@"is_read"] boolValue];
		double n1lastUpdated = [[noticfication1 valueForKey:@"last_update"] doubleValue];
		double n2lastUpdated = [[noticfication2 valueForKey:@"last_update"] doubleValue];
		
		if (n1Readed != n2Readed)
		{
			if (n1Readed)
			{
				return NSOrderedDescending;
			}
			else 
			{
				return NSOrderedAscending;
			}
		}
		else 
		{
			if (n1lastUpdated > n2lastUpdated)
			{
				return NSOrderedAscending;
			}
			else if (n1lastUpdated < n2lastUpdated)
			{
				return NSOrderedDescending;
			}
			else 
			{
				return NSOrderedSame;
			}
		}
	}
	
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

// conver between types
NSNumber * CONVER_NUMBER_FROM_STRING(NSString *string)
{
	static NSNumberFormatter * s_formatter = nil;
	
	if (nil == s_formatter)
	{
		s_formatter = [[NSNumberFormatter alloc] init];
		s_formatter.numberStyle = NSNumberFormatterNoStyle;
	}

	return [s_formatter numberFromString:string];
}

// check and error handling

BOOL CHECK_NUMBER(NSNumber *object)
{
	if ((nil != object) && [object isKindOfClass:[NSNumber class]])
	{
		return YES;
	}
	else
	{
		CLOG(@"Warning object is not an NUMBER: %@", object);
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
		CLOG(@"Warning object is not an STRING: %@", object);
		return NO;
	}
}

BOOL CHECK_DICTIONAY(NSDictionary *object)
{
	if ((nil != object) && [object isKindOfClass:[NSDictionary class]])
	{
		return YES;
	}
	else
	{
		CLOG(@"Error object is not an DICTIONARY: %@", object);
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

void ROUND_RECT(CALayer *layer)
{
	layer.cornerRadius = 8.0;
}

void CELL_BORDER(CALayer *layer)
{
	layer.borderWidth = 0.5;
	layer.borderColor = [[Color darkyellow] CGColor];
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

void CONFIG_TOOL_BAR(UIToolbar *bar)
{
	if([bar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)] ) 
	{
		//iOS 5 new UINavigationBar custom background
		[bar setBackgroundImage:[UIImage imageNamed:@"DarkGrey.png"]  
		     forToolbarPosition:UIToolbarPositionBottom 
			     barMetrics:UIBarMetricsDefault];
	} 
}

static void hide_orshow_toolbar_when_pop(UINavigationController *navco)
{
	NSArray *VCs = [navco viewControllers];
	
	if (2 <= VCs.count)
	{
		UIViewController *popVC = [VCs objectAtIndex:VCs.count - 2];
		
		if ([popVC isKindOfClass:[FoodPage class]] || [popVC isKindOfClass:[MapViewPage class]])
		{
			popVC.hidesBottomBarWhenPushed = YES;
			return;
		}
		else 
		{
			popVC.hidesBottomBarWhenPushed = NO;
		}
	}
}

static void hide_or_show_toolbar_when_push(UIViewController *vc)
{
	if ([vc isKindOfClass:[FoodPage class]] || [vc isKindOfClass:[MapViewPage class]])
	{
		vc.hidesBottomBarWhenPushed = YES;
	}
	else 
	{
		vc.hidesBottomBarWhenPushed = NO;
	}
}

void PUSH_VC(UINavigationController *navco, UIViewController *vc, BOOL animated)
{
	hide_or_show_toolbar_when_push(vc);
	
	[navco pushViewController:vc animated:animated];
}

void POP_VC(UINavigationController *navco, BOOL animated)
{
	hide_orshow_toolbar_when_pop(navco);

	[navco popViewControllerAnimated:animated];
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

	button.backgroundColor = [Color grey3];

	return button;
}

UIBarButtonItem * SETUP_BAR_BUTTON(UIImage *image,id target, SEL action)
{
	UIButton *button = SETUP_BUTTON(image, target, action);

	ROUND_RECT(button.layer);

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

const static CGFloat BUTTON_FONT_SIZE = 12.0;
const static CGFloat BUTTON_HEIGHT_PADDING = 15.0;
const static CGFloat BUTTON_WIDTH_PADDING = 25.0;

UIButton * SETUP_TEXT_BUTTON(NSString *title, id target, SEL action)
{
	static UIFont *s_font = nil;
	
	if (nil == s_font)
	{
		@autoreleasepool 
		{
			s_font = [[UIFont systemFontOfSize:BUTTON_FONT_SIZE] retain];
		}
		
	}
	
	CGSize size = [title sizeWithFont:s_font];
	size.width += BUTTON_WIDTH_PADDING;
	size.height += BUTTON_HEIGHT_PADDING;
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	
	[button.titleLabel setFont:s_font];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[Color grey1] forState:UIControlStateHighlighted];
	[button setTitleColor:[Color darkgrey] forState:UIControlStateDisabled];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	button.backgroundColor = [Color grey3];
	ROUND_RECT(button.layer);
	
	return [button autorelease];
}
UIBarButtonItem * SETUP_BAR_TEXT_BUTTON(NSString *title, id target, SEL action)
{
	UIButton *button = SETUP_TEXT_BUTTON(title, target, action);
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	return [barButton autorelease];
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
	if(score >= 10)
	{
		return @"完美之食";
	}
	else if(score >= 9)
	{
		return @"传奇美食";
	}
	else if(score >= 8.5)
	{
		return @"远超寻常";
	}
	else if(score >= 8)
	{
		return @"非比寻常";
	}
	else if(score >= 7.5)
	{
		return @"尽足本份";
	}
	else if(score >= 7)
	{
		return @"略尽本份";
	}
	else if(score >= 6.5)
	{
		return @"略有不足";
	}
	else if(score >= 6)
	{
		return @"颇有不足";
	}
	else if(score >= 5.5)
	{
		return @"也可填肚";
	}
	else if(score >= 5)
	{
		return @"勉强填肚";
	}
	else if(score >= 4)
	{
		return @"尽量不吃";
	}
	else if(score >= 3)
	{
		return @"饿都不吃";
	}
	else if(score >= 2)
	{
		return @"吃坏肚子";
	}
	else if(score > 0)
	{
		return @"会吃死人";
	} else {
		return @"未评分";
	}
}

UIColor * GET_COLOR_FOR_SCORE(double score)
{
	if (score >= 6)
	{
		return [Color blue];
	}
	else 
	{
		return [Color grey2];
	}
}

void HANDLE_MEMORY_WARNING(UIViewController *vc)
{
	if (nil == vc.view.superview)
	{
		NSMutableArray *allViewControllers =  [vc.navigationController.viewControllers mutableCopy];
		if ((![[allViewControllers objectAtIndex:0] isEqual:vc])
		    && ![[allViewControllers lastObject] isEqual:vc])
		{
			[allViewControllers removeObjectIdenticalTo:vc];
			vc.navigationController.viewControllers = allViewControllers;
		}
		
		[allViewControllers release];
	}
}


