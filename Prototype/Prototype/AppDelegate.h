//
//  AppDelegate.h
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum MSWJ_PAGE_ENUM
{
	HOME_PAGE = 0x0,
	NOTICE_PAGE = 0x1,
	SHARE_PAGE = 0x2,
	CONVERSATION_PAGE = 0x3,
	WEB_PAGE = 0x4,
	PERSONAL_SETTING_PAGE = 0x5,
	LOGOUT_PAGE = 0x6,
	MSWJ_PAGE_QUANTITY
} MSWJ_PAGE;

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (UIViewController *) currentViewController;

@end
