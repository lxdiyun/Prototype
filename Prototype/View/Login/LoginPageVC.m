//
//  LoginPageVC.m
//  Prototype
//
//  Created by Adrian Lee on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginPageVC.h"

#import "NativeLoginVC.h"
#import "SinaweiboOAuthv1LoginVC.h"
#import "DoubanOAuthv1LoginVC.h"
#import "Util.h"
#import "LoginManager.h"
#import "AppDelegate.h"
#import "Alert.h"

@interface LoginPageVC () <OAuthv1LoginDelegate>
{
	NativeLoginVC *_nativeLoginVC;
	SinaweiboOAuthv1LoginVC *_sinaLoginVC;
	DoubanOAuthv1LoginVC *_doubanLoginVC;
	Alert *_alert;
}

@property (strong, nonatomic) NativeLoginVC *nativeLoginVC;
@property (strong, nonatomic) SinaweiboOAuthv1LoginVC *sinaLoginVC;
@property (strong, nonatomic) DoubanOAuthv1LoginVC *doubanLoginVC;
@property (strong, nonatomic) Alert *alert;

@end

@implementation LoginPageVC

@synthesize nativeLoginVC = _nativeLoginVC;
@synthesize sinaLoginVC = _sinaLoginVC;
@synthesize doubanLoginVC = _doubanLoginVC;
@synthesize alert = _alert;

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		self.alert = [Alert createFromXIB];
	}

	return self;
}

- (void) dealloc
{
	self.nativeLoginVC = nil;
	self.sinaLoginVC = nil;
	self.doubanLoginVC = nil;
	self.alert = nil;
	
	[super dealloc];
}

#pragma mark - view life circle

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
	
	[super viewWillAppear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - OAuthv1LoginDelegate

- (void) oauthv1LoginDidFinishLogging:(OAuthv1BaseLoginVC *)loginViewController
{
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	NSString *accesstoken = loginViewController.accesstoken;
	NSString *tokensecret = loginViewController.tokensecret;
	NSString *userid = loginViewController.userid;
	
	[[NSUserDefaults standardUserDefaults] setObject:accesstoken forKey:OAUTH_V1_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:tokensecret forKey:OAUTH_V1_SECRET_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:userid forKey:OAUTH_V1_USER_ID_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[LoginManager changeLoginUser];
	
	self.alert.messageText = @"登陆中。。。";
	[self.alert showIn:self.view];
}

#pragma mark - action

- (void) startLoginWithAlert:(NSString *)message
{
	self.alert.messageText = message;
	[self.alert showIn:self.view];
	
	POP_VC(self.navigationController, NO);
}

- (void) startLoginWithNoAlert
{
	POP_VC(self.navigationController, NO);
	[self.alert dismiss];
}

- (void) cleanInfo
{
	[self.nativeLoginVC cleanLoginInfo];
	[self.sinaLoginVC cleanLoginInfo];
	[self.doubanLoginVC cleanLoginInfo];
}

- (void) newUserLogin
{
	NSNumber *loginType = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_TYPE_KEY];
	
	switch ([loginType intValue]) 
	{
		case LOGIN_SINA:
			[self.sinaLoginVC newUserLogin];
			break;
			
		default:
			break;
	}
	
	[AppDelegate showPage:USER_INFO_PAGE];
}

- (IBAction) nativeLogin:(id)sender 
{
	if (nil == self.nativeLoginVC)
	{
		NativeLoginVC *nativeLoginVC = [[NativeLoginVC alloc] init];
		
		self.nativeLoginVC = nativeLoginVC;
		
		[nativeLoginVC release];
	}
	
	PUSH_VC(self.navigationController, self.nativeLoginVC, YES);
}

- (IBAction) sinaLogin:(id)sender 
{
	if (nil == self.sinaLoginVC)
	{
		SinaweiboOAuthv1LoginVC *sineLoginVC = [[SinaweiboOAuthv1LoginVC alloc] init];
		sineLoginVC.delegate = self;
		self.sinaLoginVC = sineLoginVC;
		
		[sineLoginVC release];
	}

	PUSH_VC(self.navigationController, self.sinaLoginVC, YES);
	[self.sinaLoginVC startLogin];
}

- (IBAction) doubanLogin:(id)sender 
{
	if (nil == self.doubanLoginVC)
	{
		DoubanOAuthv1LoginVC *doubanLoginVC = [[DoubanOAuthv1LoginVC alloc] init];
		doubanLoginVC.delegate = self;
		self.doubanLoginVC = doubanLoginVC;
		
		[doubanLoginVC release];
	}
	
	PUSH_VC(self.navigationController, self.doubanLoginVC, YES);
	[self.doubanLoginVC startLogin];
}

- (IBAction) registerNewUser:(id)sender 
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.meishiwanjia.com/"]];
}

@end
