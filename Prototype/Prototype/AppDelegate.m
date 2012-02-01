//
//  AppDelegate.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "EventPage.h"
#import "UserInfoPage.h"
#import "ShareNewEvent.h"
#import "Util.h"
#import "ObjectSaver.h"

typedef enum MSWJ_PAGE_ENUM
{
	HOME_PAGE = 0x0,
	NOTICE_PAGE = 0x1,
	SHARE_PAGE = 0x2,
	PRIVATE_MESSAGE_PAGE = 0x3,
	PERSONAL_SETTING_PAGE = 0x4,
	MSWJ_PAGE_QUANTITY
} MSWJ_PAGE;

static NSString *MSWJ_PAGE_NAME[MSWJ_PAGE_QUANTITY] = {@"新鲜事", @"通知", @"分享美食", @"私信", @"个人设置", };
static NSString *MSWJ_ICON[MSWJ_PAGE_QUANTITY] = {@"HomePage.png", @"Notice.png", @"Share.png", @"PrivateMessage.png", @"More.png"};
static Class MSWJ_PAGE_CLASS[MSWJ_PAGE_QUANTITY]; 
static UIViewController *MSWJ_PAGE_INSTANCE[MSWJ_PAGE_QUANTITY] = {nil};
static UIViewController *gs_currentViewController;


@interface AppDelegate () <UITabBarControllerDelegate>
{
	UITabBarController *_tabco;
}
@property (strong, nonatomic) UITabBarController *tabco;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabco = _tabco;

#pragma mark - life circle

- (void) setupPageClass
{
	MSWJ_PAGE_CLASS[HOME_PAGE] = [EventPage class];
	MSWJ_PAGE_CLASS[NOTICE_PAGE] = [UIViewController class];
	MSWJ_PAGE_CLASS[SHARE_PAGE] = [ShareNewEvent class];
	MSWJ_PAGE_CLASS[PRIVATE_MESSAGE_PAGE] = [UIViewController class];
	MSWJ_PAGE_CLASS[PERSONAL_SETTING_PAGE] = [UserInfoPage class];
}

- (void) initPageClass
{
	for (int i = 0; i < MSWJ_PAGE_QUANTITY; ++i)
	{
		if (nil == MSWJ_PAGE_INSTANCE[i])
		{
			MSWJ_PAGE_INSTANCE[i] = [[MSWJ_PAGE_CLASS[i] alloc] init];
			MSWJ_PAGE_INSTANCE[i].title = MSWJ_PAGE_NAME[i];
		}
	}
}

- (void) releasePageInstance
{
	for (int i = 0; i < MSWJ_PAGE_QUANTITY; ++i)
	{
		[MSWJ_PAGE_INSTANCE[i] release];
		MSWJ_PAGE_CLASS[i] = nil;
	}
}

- (void) dealloc
{
	self.tabco = nil;
	[self releasePageInstance];
	
	[_window release];
	[super dealloc];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// restore cache
	[ObjectSaver restoreAll];
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	// Override point for customization after application launch.
	self.window.backgroundColor = [Color whiteColor];
	
	// init and show page 
	[self setupPageClass];
	
	[self initPageClass];
	
	NSMutableArray *tabBarViewControllers = [[NSMutableArray alloc] initWithCapacity:MSWJ_PAGE_QUANTITY];
	UITabBarController *tabBarController = [[UITabBarController alloc] init];
	
	for (int i = 0; i < MSWJ_PAGE_QUANTITY; ++i)
	{
		UINavigationController *navco = [[UINavigationController alloc] initWithRootViewController:MSWJ_PAGE_INSTANCE[i]];
		[tabBarViewControllers addObject:navco];
		navco.navigationBar.barStyle = UIBarStyleBlack;
		navco.tabBarItem.image = [UIImage imageNamed:MSWJ_ICON[i]];
		[navco release];
	}
	
	tabBarController.viewControllers = tabBarViewControllers;
	
	self.tabco = tabBarController;
	self.tabco.delegate = self;
	
	gs_currentViewController = self.tabco;
	
	[[[self.tabco.viewControllers objectAtIndex:1] tabBarItem] setBadgeValue:@"2"];

	[self.window addSubview:self.tabco.view];

	[tabBarController release];
	[tabBarViewControllers release];
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	/*
	 TODO
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	[ObjectSaver saveAll];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	[ObjectSaver restoreAll];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void) applicationWillTerminate:(UIApplication *)application
{
	[ObjectSaver saveAll];
}

#pragma mark - UITabBarDelegate

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController

{
	if ([tabBarController.viewControllers objectAtIndex:SHARE_PAGE] == viewController)
	{
		ShareNewEvent *sharer = (ShareNewEvent *)MSWJ_PAGE_INSTANCE[SHARE_PAGE];
		
		sharer.delegate = self.tabco;

		[sharer start];
		
		return NO;
	}
	else
	{
		return YES;
	}
}

#pragma mark - class interface

+ (UIViewController *) currentViewController
{
	return gs_currentViewController;
}

@end
