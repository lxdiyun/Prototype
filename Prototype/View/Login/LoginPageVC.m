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

@interface LoginPageVC () <OAuthv1LoginDelegate>
{
	NativeLoginVC *_nativeLoginVC;
	SinaweiboOAuthv1LoginVC *_sinaLoginVC;
	DoubanOAuthv1LoginVC *_doubanLoginVC;
}

@property (strong) NativeLoginVC *nativeLoginVC;
@property (strong) SinaweiboOAuthv1LoginVC *sinaLoginVC;
@property (strong) DoubanOAuthv1LoginVC *doubanLoginVC;

@end

@implementation LoginPageVC

@synthesize nativeLoginVC = _nativeLoginVC;
@synthesize sinaLoginVC = _sinaLoginVC;
@synthesize doubanLoginVC = _doubanLoginVC;

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		// Custom initialization
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
	
	[super viewWillAppear:animated];
}

- (void) viewDidUnload
{
	self.nativeLoginVC = nil;
	self.sinaLoginVC = nil;
	self.doubanLoginVC = nil;
	
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	self.nativeLoginVC = nil;
	self.sinaLoginVC = nil;
	self.doubanLoginVC = nil;

	[super dealloc];
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
}

#pragma mark - action

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
	
	[AppDelegate showPage:PERSONAL_SETTING_PAGE];
}

- (IBAction) nativeLogin:(id)sender 
{
	if (nil == self.nativeLoginVC)
	{
		NativeLoginVC *nativeLoginVC = [[NativeLoginVC alloc] init];
		
		self.nativeLoginVC = nativeLoginVC;
		
		[nativeLoginVC release];
	}
	
	[self.navigationController pushViewController:self.nativeLoginVC animated:YES];
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

	[self.navigationController pushViewController:self.sinaLoginVC animated:YES];
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
	
	[self.navigationController pushViewController:self.doubanLoginVC animated:YES];
	[self.doubanLoginVC startLogin];
}

- (IBAction) registerNewUser:(id)sender 
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.meishiwanjia.com/"]];
}

@end
