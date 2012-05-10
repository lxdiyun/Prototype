//
//  AppDelegate.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h>

#import "EventPage.h"
#import "UserInfoPage.h"
#import "ShareNewEvent.h"
#import "Util.h"
#import "ObjectSaver.h"
#import "ConversationPage.h"
#import "WebPage.h"
#import "FoodMapListPage.h"
#import "LogoutPage.h"

static NSString *MSWJ_PAGE_NAME[MSWJ_PAGE_QUANTITY] = {@"新鲜事", @"美食地图", @"分享美食", @"私信", @"Web", @"个人设置",@"注销"};
static NSString *MSWJ_ICON[MSWJ_PAGE_QUANTITY] = {@"HomePage.png", @"FoodMap.png", @"Share.png", @"PrivateMessage.png", @"More.png", @"UserInfo.png", @"Logout.png"};
static Class MSWJ_PAGE_CLASS[MSWJ_PAGE_QUANTITY]; 
static UIViewController *MSWJ_PAGE_INSTANCE[MSWJ_PAGE_QUANTITY] = {nil};
static UIViewController *gs_currentViewController;

@interface AppDelegate () <UITabBarControllerDelegate>
{
	UITabBarController *_tabco;
}
@property (strong) UITabBarController *tabco;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabco = _tabco;

#pragma mark - life circle

- (void) setupPageClass
{
	MSWJ_PAGE_CLASS[HOME_PAGE] = [EventPage class];
	MSWJ_PAGE_CLASS[NOTICE_PAGE] = [FoodMapListPage class];
	MSWJ_PAGE_CLASS[SHARE_PAGE] = [ShareNewEvent class];
	MSWJ_PAGE_CLASS[CONVERSATION_PAGE] = [ConversationPage class];
	MSWJ_PAGE_CLASS[WEB_PAGE] = [WebPage class];
	MSWJ_PAGE_CLASS[PERSONAL_SETTING_PAGE] = [UserInfoPage class];
	MSWJ_PAGE_CLASS[LOGOUT_PAGE] = [LogoutPage class];
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
		CONFIG_NAGIVATION_BAR(navco.navigationBar);
		[tabBarViewControllers addObject:navco];
		navco.tabBarItem.image = [UIImage imageNamed:MSWJ_ICON[i]];

		[navco release];
	}
	
	[tabBarController setViewControllers:tabBarViewControllers animated:NO];
	tabBarController.delegate = self;
	
	// configure more view
	CONFIG_NAGIVATION_BAR(tabBarController.moreNavigationController.navigationBar);
	tabBarController.customizableViewControllers = nil;
	UITableView *moreView = (UITableView *)tabBarController.moreNavigationController.topViewController.view;
	if ([moreView isKindOfClass:[UITableView class]])
	{
		moreView.backgroundColor = [Color lightyellowColor];
		[moreView setSeparatorColor:[UIColor blackColor]];
	}
	
	self.tabco = tabBarController;
	
	gs_currentViewController = self.tabco;

	[self.window addSubview:self.tabco.view];

	[tabBarViewControllers release];
	
	// restore cache
	[ObjectSaver restoreAll];
	
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
	else if ([tabBarController.viewControllers objectAtIndex:LOGOUT_PAGE] == viewController)
	{
		LogoutPage *logoutPage = (LogoutPage *)MSWJ_PAGE_INSTANCE[LOGOUT_PAGE];
		[logoutPage confirmLogout];
		
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

+ (void) resetAllPage
{
	for (int i = 0; i < MSWJ_PAGE_QUANTITY; ++i)
	{
		[MSWJ_PAGE_INSTANCE[i].navigationController popToRootViewControllerAnimated:NO];
	}
	
	[EventPage requestUpdate];
	[EventPage reloadData];
	[UserInfoPage reloadData];
	[FoodMapListPage reloadData];
}

+ (void) showPage:(MSWJ_PAGE)page
{
	if ((HOME_PAGE <= page) && (page <= MSWJ_PAGE_QUANTITY))
	{
		if ([gs_currentViewController isKindOfClass:[UITabBarController class]])
		{
			[(UITabBarController *)gs_currentViewController setSelectedIndex:page];
		}
	}
}

@end
