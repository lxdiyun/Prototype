//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginManager.h"

#import "Util.h"
#import "Message.h"
#import "NetworkService.h"
#import "LoginPage.h"
#import "AppDelegate.h"
#import "ObjectSaver.h"
#import "UserInfoPage.h"
#import "EventPage.h"

static NSString *gs_fakeLoginStringID;
static UINavigationController *gs_login_page_nvc;
static LoginPage *gs_login_page;

@implementation LoginManager

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if(nil != self)
	{
		// init data
		if (nil == gs_fakeLoginStringID)
		{
			gs_fakeLoginStringID = [[NSString alloc] initWithFormat:@"%d", 0x1];
		}
		
		if (nil == gs_login_page)
		{
			gs_login_page = [[LoginPage alloc] init];
		}
		
		if (nil == gs_login_page_nvc)
		{
			gs_login_page_nvc = [[UINavigationController alloc] initWithRootViewController:gs_login_page];
			gs_login_page_nvc.navigationBar.barStyle = UIBarStyleBlack;
		}
	}
	
	return self;
}

- (void) dealloc
{
	[gs_fakeLoginStringID release];
	gs_fakeLoginStringID = nil;
	[gs_login_page release];
	gs_login_page = nil;
	[gs_login_page_nvc release];
	gs_login_page_nvc = nil;
	[super dealloc];
}

#pragma mark - singleton

DEFINE_SINGLETON(LoginManager);

+ (void) request
{
	@autoreleasepool 
	{
		if ([self isUpdatingObjectStringID:gs_fakeLoginStringID])
		{
			return;
		}
		
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		
		NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_account"];
		NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_password"];

		if ((nil != account) && (nil != password))
		{
			// TODO update to real login user information
			[params setValue:account forKey:@"username"];
			[params setValue:password forKey:@"pwd"];
			
			[request setValue:@"sys.login" forKey:@"method"];
			[request setValue:params forKey:@"params"];
			
			[self markUpdatingStringID:gs_fakeLoginStringID];
			
			SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
							       gs_shared_instance, 
							       @selector(handlerForResult:), 
							       HIGHEST_PRIORITY);
		}
	}
}

+ (void) requestWithHandler:(SEL)handler andTarget:(id)target
{	
	[self bindStringID:gs_fakeLoginStringID withHandler:handler andTarget:target];
	
	[self request];
}

- (void) handlerForResult:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}

	[[self class] cleanUpdatingStringID:gs_fakeLoginStringID];

	NSNumber *loginUserID = [result valueForKey:@"result"];
	
	if (nil != loginUserID)
	{
		SET_USER_ID(loginUserID);
		
		[EventPage requestUpdate];
		[EventPage reloadData];
		[UserInfoPage reloadData];
		
		if ([[AppDelegate currentViewController] modalViewController] == gs_login_page_nvc)
		{
			[[AppDelegate currentViewController] dismissModalViewControllerAnimated:YES];
		}
		
		[self checkAndPerformResponderWithID:gs_fakeLoginStringID];
		
		START_PING();
	}
	else
	{
		[NetworkService stop];

		NSString *errorMessage = [result valueForKey:@"error"];
		if (nil != errorMessage)
		{
			gs_login_page.errorMessage = errorMessage;
			
			[gs_login_page.tableView reloadData];
		}

		if ([[AppDelegate currentViewController] modalViewController] != gs_login_page_nvc)
		{
			[[AppDelegate currentViewController] presentModalViewController:gs_login_page_nvc animated:YES];
		}
	}
}

+ (void) handleNotLoginMessage:(id)messsge
{
	[NetworkService stop];
	
	if ([[AppDelegate currentViewController] modalViewController] != gs_login_page_nvc)
	{
		gs_login_page.errorMessage = nil;
		
		[gs_login_page.tableView reloadData];

		[[AppDelegate currentViewController] presentModalViewController:gs_login_page_nvc animated:YES];
	}
}

+ (void) changeLoginUser
{
	[NetworkService reconnect];
	
	[self request];
}

+ (void) logoutCurrentUser
{
	[NetworkService stop];
	[ObjectSaver resetUserInfo];
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user_account"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user_password"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([[AppDelegate currentViewController] modalViewController] != gs_login_page_nvc)
	{
		gs_login_page.errorMessage = nil;

		[gs_login_page reloadData];
		
		[[AppDelegate currentViewController] presentModalViewController:gs_login_page_nvc animated:YES];
	}
}

@end
