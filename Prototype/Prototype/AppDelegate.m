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


@interface AppDelegate () <UITabBarControllerDelegate>
{
@private
	UITabBarController *_tabco;
	
}

@property (strong, nonatomic) UITabBarController *tabco;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
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

- (void)dealloc
{
	self.tabco = nil;
	[self releasePageInstance];
	
	[_window release];
	[__managedObjectContext release];
	[__managedObjectModel release];
	[__persistentStoreCoordinator release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// restore cache
	[ObjectSaver restoreAll];
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	// Override point for customization after application launch.
	self.window.backgroundColor = [Color whiteColor];
	
	// set status bar style
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
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
	
	[[[self.tabco.viewControllers objectAtIndex:1] tabBarItem] setBadgeValue:@"2"];

	[self.window addSubview:self.tabco.view];

	[tabBarController release];
	[tabBarViewControllers release];
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[ObjectSaver saveAll];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[ObjectSaver restoreAll];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[ObjectSaver saveAll];
	[self saveContext];
}

- (void)saveContext
{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil)
	{
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
		{
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
			 */
			LOG(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		} 
	}
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
	if (__managedObjectContext != nil)
	{
		return __managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		__managedObjectContext = [[NSManagedObjectContext alloc] init];
		[__managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
	if (__managedObjectModel != nil)
	{
		return __managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Prototype" withExtension:@"momd"];
	__managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (__persistentStoreCoordinator != nil)
	{
		return __persistentStoreCoordinator;
	}
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Prototype.sqlite"];
	
	NSError *error = nil;
	__persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 Check the error message to determine what the actual problem was.
		 
		 
		 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
		 
		 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
		 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		 
		 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
		 
		 */
		LOG(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}    
	
	return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *) applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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

@end
