//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginManager.h"

#import <ytoolkit/yoauthv1.h>

#import "Util.h"
#import "Message.h"
#import "NetworkService.h"
#import "AppDelegate.h"
#import "ObjectSaver.h"
#import "UserInfoPage.h"
#import "EventPage.h"
#import "LoginPageVC.h"
#import "SDImageCache.h"

NSString * const LOGIN_TYPE_KEY = @"meishiwanjia_login_type";

NSString * const SINA_OAUTH_V1_TOKEN_USERID = @"user_id";
NSString * const DOUBAN_OAUTH_V1_TOKEN_USERID = @"douban_user_id";
NSString * const OAUTH_V1_TOKEN_USERID = @"user_id";
NSString * const OAUTH_V1_TOKEN_KEY = @"meishiwanjia_oauth_v1_token";
NSString * const OAUTH_V1_SECRET_KEY = @"meishiwanjia_oauth_v1_secret";
NSString * const OAUTH_V1_USER_ID_KEY = @"meishiwanjia_oauth_v1_user_id";

NSString * const NATIVE_ACCOUNT_KEY = @"meishiwanjia_user_account";
NSString * const NATIVE_PASSWORD_KEY = @"meishiwanjia_user_password";

static NSString *gs_fakeLoginStringID;
static UINavigationController *gs_login_page_nvc;
static LoginPageVC *gs_login_page;

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
			gs_login_page = [[LoginPageVC alloc] init];
		}
		
		if (nil == gs_login_page_nvc)
		{
			gs_login_page_nvc = [[UINavigationController alloc] initWithRootViewController:gs_login_page];
			CONFIG_NAGIVATION_BAR(gs_login_page_nvc.navigationBar);
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

#pragma mark - login action

+ (BOOL) requestNativeLogin
{
	NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
	
	NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:NATIVE_ACCOUNT_KEY];
	NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:NATIVE_PASSWORD_KEY];
	
	if ((nil != account) && (nil != password))
	{
		[params setValue:account forKey:@"username"];
		[params setValue:password forKey:@"pwd"];
		
		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		
		[self markUpdatingStringID:gs_fakeLoginStringID];
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       gs_shared_instance, 
						       @selector(handlerForNativeLoginResult:), 
						       HIGHEST_PRIORITY);
		
		return YES;
	}
	else 
	{
		return NO;
	}
}

+ (BOOL) requestOAuthLogin:(NSNumber *)loginType
{
	NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
	
	NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:OAUTH_V1_TOKEN_KEY];
	NSString *secret = [[NSUserDefaults standardUserDefaults] objectForKey:OAUTH_V1_SECRET_KEY];
	NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:OAUTH_V1_USER_ID_KEY];
	
	if ((nil != token) && (nil != secret) && (nil != userid))
	{
		[params setValue:loginType forKey:@"source"];
		[params setValue:token forKey:YOAuthv1OAuthTokenKey];
		[params setValue:secret forKey:YOAuthv1OAuthTokenSecretKey];
		[params setValue:userid forKey:OAUTH_V1_TOKEN_USERID];
		
		[request setValue:@"sys.login_oauthv1" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		
		[self markUpdatingStringID:gs_fakeLoginStringID];
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       gs_shared_instance, 
						       @selector(handlerForOAuthV1LoginResult:), 
						       HIGHEST_PRIORITY);
		
		return YES;
	}
	else 
	{
		return NO;
	}
}

+ (void) request
{
	@autoreleasepool 
	{
		if ([self isUpdatingObjectStringID:gs_fakeLoginStringID])
		{
			return;
		}
		
		NSNumber *loginType = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_TYPE_KEY];
		BOOL requestSuccess = NO;

		switch ([loginType intValue]) 
		{
			case LOGIN_NATIVE:
				requestSuccess = [self requestNativeLogin];
				break;
			case LOGIN_SINA:
			case LOGIN_DOUBAN:
				requestSuccess = [self requestOAuthLogin:loginType];
			default:
				break;
		}
		
		if (!requestSuccess)
		{
			LOG(@"Error: login params not valid");

			[self cleanUpdatingStringID:gs_fakeLoginStringID];
			
			[self handleNotLogin];
		}
		
	}
}

+ (void) requestWithHandler:(SEL)handler andTarget:(id)target
{	
	[self bindStringID:gs_fakeLoginStringID withHandler:handler andTarget:target];
	
	[self request];
}

- (void) handleLoginFailedResult:(id)result
{
	[NetworkService stop];
	
	NSString *errorMessage = [result valueForKey:@"error"];
	if (nil != errorMessage)
	{
		SHOW_ALERT_TEXT(@"登录失败", errorMessage);
		[gs_login_page_nvc popToRootViewControllerAnimated:YES];
	}
	
	if ([[AppDelegate currentViewController] modalViewController] != gs_login_page_nvc)
	{
		[[AppDelegate currentViewController] presentModalViewController:gs_login_page_nvc animated:YES];
	}
}

- (void) handlerForNativeLoginResult:(id)result
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
		
		if ([[AppDelegate currentViewController] modalViewController] == gs_login_page_nvc)
		{
			[[AppDelegate currentViewController] dismissModalViewControllerAnimated:YES];
		}
		
		[self checkAndPerformResponderWithID:gs_fakeLoginStringID];
		
		START_PING();
	}
	else
	{
		[self handleLoginFailedResult:result];
	}
}

- (void) handlerForOAuthV1LoginResult:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	[[self class] cleanUpdatingStringID:gs_fakeLoginStringID];
	
	NSNumber *loginUserID = [[result valueForKey:@"result"] valueForKey:@"user_id"];
	
	if (nil != loginUserID)
	{
		SET_USER_ID(loginUserID);
		
		// handle new user login
		BOOL isNewUser = [[[result valueForKey:@"result"] valueForKey:@"new_user"] boolValue];
		
		if (isNewUser)
		{
			[gs_login_page newUserLogin];
		}
		
		// remove login view
		if ([[AppDelegate currentViewController] modalViewController] == gs_login_page_nvc)
		{
			[[AppDelegate currentViewController] dismissModalViewControllerAnimated:YES];
		}
		
		// excute login request pending action
		[self checkAndPerformResponderWithID:gs_fakeLoginStringID];
		
		START_PING();
	}
	else
	{
		[self handleLoginFailedResult:result];
	}
}

+ (void) handleNotLoginMessage:(id)messsge
{
	[NetworkService stop];
	
	[self handleNotLogin];
}

+ (void) changeLoginUser
{
	[NetworkService reconnect];
	
	[self request];
}

+ (void) handleNotLogin
{
	if ([[AppDelegate currentViewController] modalViewController] != gs_login_page_nvc)
	{
		[gs_login_page startLogin];
	}
}

#pragma mark - logout action

+ (void) logoutCurrentUser
{
	[NetworkService stop];
	[ObjectSaver resetUserInfo];
	
	// clean cookie
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]) 
	{
		[storage deleteCookie:cookie];
	}
	
	// clean NSUserDefaults
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier]; 
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// clean image cache
	[[SDImageCache sharedImageCache] clearMemory];
	[[SDImageCache sharedImageCache] clearDisk];
	
	[gs_login_page cleanInfo];

	[self handleNotLogin];
	
	[AppDelegate resetAllPage];
}

#pragma mark - save and restore

+ (void) saveTo:(NSMutableDictionary *)dict
{
	NSNumber *loginUserID = GET_USER_ID();
	
	if (nil != loginUserID)
	{
		[dict setObject: loginUserID forKey:[self description]];
	}
}

+ (void) restoreFrom:(NSDictionary *)dict
{
	@autoreleasepool 
	{
		NSNumber *loginUserID = [dict objectForKey:[self description]];
		
		if (nil != loginUserID)
		{
			SET_USER_ID(loginUserID);
		}
	}
}

@end
