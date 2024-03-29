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
#import "MyHomePage.h"
#import "ShareNewEvent.h"
#import "Util.h"
#import "ObjectSaver.h"
#import "NewsPage.h"
#import "PublicFoodMapListPage.h"
#import "LogoutPage.h"
#import "ConversationListManager.h"
#import "NotificationManager.h"

static NSString *MSWJ_PAGE_NAME[MSWJ_PAGE_QUANTITY] = {@"新鲜事", @"美食地图", @"分享美食", @"消息", @"我的主页", @"个人设置",@"注销"};
static NSString *MSWJ_ICON[MSWJ_PAGE_QUANTITY] = {@"HomePage.png", @"FoodMap.png", @"Share.png", @"News.png", @"MyHomePage.png", @"UserInfo.png", @"Logout.png"};
static Class MSWJ_PAGE_CLASS[MSWJ_PAGE_QUANTITY]; 
static UIViewController *MSWJ_PAGE_INSTANCE[MSWJ_PAGE_QUANTITY] = {nil};
static UIViewController *gs_currentViewController;

@interface AppDelegate () <UITabBarControllerDelegate, UITableViewDelegate>
{
	UITabBarController *_tabco;
	id<UITableViewDelegate> _moreOriginDelegate;
}
@property (strong, nonatomic) UITabBarController *tabco;
@property (assign, nonatomic) id<UITableViewDelegate> moreOriginDelegate;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabco = _tabco;
@synthesize moreOriginDelegate = _moreOriginDelegate;

#pragma mark - life circle

- (void) setupPageClass
{
	MSWJ_PAGE_CLASS[EVENT_PAGE] = [EventPage class];
	MSWJ_PAGE_CLASS[NOTICE_PAGE] = [PublicFoodMapListPage class];
	MSWJ_PAGE_CLASS[SHARE_PAGE] = [ShareNewEvent class];
	MSWJ_PAGE_CLASS[NEWS_PAGE] = [NewsPage class];
	MSWJ_PAGE_CLASS[MY_HOME_PAGE] = [MyHomePage class];
	MSWJ_PAGE_CLASS[USER_INFO_PAGE] = [UserInfoPage class];
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
	self.window.backgroundColor = [UIColor whiteColor];
	
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
	tabBarController.customizableViewControllers = nil;
	tabBarController.delegate = self;
	
	self.tabco = tabBarController;
	
	gs_currentViewController = self.tabco;

	[self.window addSubview:self.tabco.view];

	[tabBarViewControllers release];
	
	// restore cache
	[ObjectSaver restoreAll];
	// check news
	[NotificationManager checkNew];
	[ConversationListManager checkNew];
	
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
	// restore cache
	[ObjectSaver restoreAll];
	// check news
	[NotificationManager checkNew];
	[ConversationListManager checkNew];
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
	if (viewController == [tabBarController.viewControllers objectAtIndex:SHARE_PAGE])
	{
		ShareNewEvent *sharer = (ShareNewEvent *)MSWJ_PAGE_INSTANCE[SHARE_PAGE];
		
		sharer.delegate = self.tabco;

		[sharer start];
		
		return NO;
	} 
	else if ((viewController == tabBarController.moreNavigationController) 
		 && (nil == tabBarController.moreNavigationController.delegate)) 
	{ 
		
		[tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];

		// configure more view
		UITableView *view = (UITableView *)tabBarController.moreNavigationController.topViewController.view;
		
		CONFIG_NAGIVATION_BAR(tabBarController.moreNavigationController.navigationBar);
		
		if ([view isKindOfClass:[UITableView class]])
		{
			view.backgroundColor = [Color lightyellow];
			[view setSeparatorColor:[Color darkyellow]];
			
			if (view.delegate != self)
			{
				self.moreOriginDelegate = view.delegate;
				view.delegate = self;
			}
		}
		
		return YES;
	}
	else if (viewController == [tabBarController.viewControllers objectAtIndex:LOGOUT_PAGE])
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
	[EventPage cleanAndRefresh];
	[UserInfoPage reloadData];
}

+ (void) showPage:(MSWJ_PAGE)page
{
	if ((EVENT_PAGE <= page) && (page <= MSWJ_PAGE_QUANTITY))
	{
		if ([gs_currentViewController isKindOfClass:[UITabBarController class]])
		{
			[(UITabBarController *)gs_currentViewController setSelectedIndex:page];
		}
	}
}

#pragma mark - UITableViewDelegate - for more tab

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if  (LOGOUT_PAGE == (indexPath.row + MORE_PAGE_INDEX))
	{
		LogoutPage *logoutPage = (LogoutPage *)MSWJ_PAGE_INSTANCE[LOGOUT_PAGE];
		[logoutPage confirmLogout];
		
		return nil;
	}

	return indexPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.moreOriginDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
