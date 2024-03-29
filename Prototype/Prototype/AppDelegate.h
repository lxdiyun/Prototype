//
//  AppDelegate.h
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

const static NSInteger MORE_PAGE_INDEX = 0x4;

typedef enum MSWJ_PAGE_ENUM
{
	EVENT_PAGE = 0x0,
	NOTICE_PAGE = 0x1,
	SHARE_PAGE = 0x2,
	NEWS_PAGE = 0x3,
	MY_HOME_PAGE = 0x4,
	USER_INFO_PAGE = 0x5,
	LOGOUT_PAGE = 0x6,
	MSWJ_PAGE_QUANTITY
} MSWJ_PAGE;

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (UIViewController *) currentViewController;
+ (void) resetAllPage;
+ (void) showPage:(MSWJ_PAGE)page;

@end
