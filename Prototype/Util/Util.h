//
//  Util.h
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef  _UTIL_H_
#define  _UTIL_H_

#import <Foundation/Foundation.h>

#import "Util_Macro.h"
#import "Color.h"

@protocol ShowVCDelegate <NSObject>

- (void) showVC:(UIViewController *)vc;

@end

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

// food score text and color

NSString * GET_STRING_FOR_SCORE(double score);
NSString * GET_DESC_FOR_SCORE(double score);
UIColor * GET_COLOR_FOR_SCORE(double score);

#endif
