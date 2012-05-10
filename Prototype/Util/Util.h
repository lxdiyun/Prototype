//
//  Util.h
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef  _UTIL_H_
#define  _UTIL_H_

#include <libgen.h>

// LOG
#ifdef DEBUG
#define LOG(format, ...) { NSLog(@"%s %s %d:", basename(__FILE__), (char *)_cmd, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define LOG(format, ...)
#endif

#ifdef DEBUG
#define CLOG(format, ...) { NSLog(@"%s %s %d:", basename(__FILE__), __func__, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define CLOG(format, ...)
#endif

// singleton
#if (!__has_feature(objc_arc))
#define ARC_SINGLETON \
- (id) retain \
{ \
return self; \
} \
- (unsigned) retainCount \
{ \
return UINT_MAX;  \
}\
\
- (oneway void) release \
{\
}\
- (id) autorelease \
{ \
return self; \
}
#else
#define ARC_SINGLETON
#endif

#define DEFINE_SINGLETON(CLASS_NAME) \
static CLASS_NAME *gs_shared_instance; \
+ (id) allocWithZone:(NSZone *)zone \
{ \
	if ([CLASS_NAME class] == self) \
	{ \
		return [gs_shared_instance retain]; \
	} \
	else \
	{ \
		return [super allocWithZone:zone]; \
	} \
} \
- (id) copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
ARC_SINGLETON \
+ (void) initialize \
{ \
	if (self == [CLASS_NAME class]) \
	{ \
		gs_shared_instance = [[super allocWithZone:nil] init]; \
	} \
} \
+ (id) getInstnace \
{\
	return gs_shared_instance; \
}

#import <Foundation/Foundation.h>

// const variable
const static CGFloat TAB_BAR_HEIGHT = 49;
const static CGFloat STATUS_BAR_HEIGHT = 20;

// login user id
NSNumber * GET_USER_ID(void);
void SET_USER_ID(NSNumber *ID);

// sorter
// hight ID => low ID
NSInteger ID_SORTER(id ID1, id ID2, void *context);
// low ID => hight ID
NSInteger ID_SORTER_REVERSE(id ID1, id ID2, void *context);
// map annotation view from left top to right bottom 
NSInteger MAP_ANNOTATION_VIEW_SORTER(id view1, id view2, void *context);


// Network Indicator
void START_NETWORK_INDICATOR(void);
void STOP_NETWORK_INDICATOR(void);
void STOP_ALL_NETWORK_INDICATOR(void);

// view
CGFloat SCALE(void);
CGFloat PROPORTION(void);
NSInteger DEVICE_TYPE(void);

// check and error handling;
BOOL CHECK_NUMBER(NSNumber *object);
BOOL CHECK_STRING(NSString *object);

// alert
void SHOW_ALERT_TEXT(NSString *title, NSString *message);

@interface Color : NSObject 

+ (UIColor *) whiteColor;
+ (UIColor *) milkColor;
+ (UIColor *) orangeColor;
+ (UIColor *) grey1Color;
+ (UIColor *) grey2Color;
+ (UIColor *) grey3Color;
+ (UIColor *) darkgreyColor;
+ (UIColor *) brownColor;
+ (UIColor *) blackColorAlpha;
+ (UIColor *) tastyColor;
+ (UIColor *) specailColor;
+ (UIColor *) valuedColor;
+ (UIColor *) healthyColor;
+ (UIColor *) lightyellowColor;

@end

// custom nagivation bar
// for iOS < 5.0
@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
	UIColor *color = [Color darkgreyColor];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
	CGContextFillRect(context, rect);
}
@end
// for ios > 5.0
void CONFIG_NAGIVATION_BAR(UINavigationBar *bar);

// custom button style
UIButton * SETUP_BACK_BUTTON(id target, SEL action);
UIBarButtonItem * SETUP_BACK_BAR_BUTTON(id target, SEL action);
UIButton * SETUP_BUTTON(UIImage *image,id target, SEL action);
UIBarButtonItem * SETUP_BAR_BUTTON(UIImage *image,id target, SEL action);
UIButton * SETUP_TEXT_BUTTON(NSString *title, id target, SEL action);
UIBarButtonItem * SETUP_BAR_TEXT_BUTTON(NSString *title, id target, SEL action);

#endif
