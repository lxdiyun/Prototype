//
//  NativeLoginVC.m
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NativeLoginVC.h"

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>

#import "Util.h"
#import "LoginManager.h"
#import "LoginManager.h"

@interface NativeLoginVC () 

@end

@implementation NativeLoginVC
@synthesize account;
@synthesize password;
@synthesize accountLabel;
@synthesize passwordLabel;

#pragma mark - life circle

- (void) setupButtons
{
	@autoreleasepool 
	{
		UIButton *loginButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 28)] autorelease];
		[loginButton setTitle:@"登陆" forState:UIControlStateNormal];
		[loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[loginButton setTitleColor:[Color grey2Color] forState:UIControlStateHighlighted];
		[loginButton setTitleColor:[Color grey2Color] forState:UIControlStateDisabled];
		loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		loginButton.layer.cornerRadius = 8.0;
		loginButton.backgroundColor = [Color grey3Color];
		[loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *loginItem = [[[UIBarButtonItem alloc] initWithCustomView:loginButton] autorelease];
		
		self.navigationItem.rightBarButtonItem = loginItem;
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self.navigationController, @selector(popViewControllerAnimated:));
	}

}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		[self setupButtons];
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.accountLabel.layer.cornerRadius = 8.0;
	self.passwordLabel.layer.cornerRadius = 8.0;
	
	self.title = @"美食玩家";
}

- (void) viewDidUnload
{
	[self setPassword:nil];
	[self setAccount:nil];
	[self setAccountLabel:nil];
	[self setPasswordLabel:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
	[super viewWillAppear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	[password release];
	[account release];
	[accountLabel release];
	[passwordLabel release];
	[super dealloc];
}


#pragma mark - login action

- (BOOL) checkParamsNotEmpty
{
	BOOL paramsReady = YES;
	
	if (0 >= self.account.text.length)
	{
		paramsReady = NO;
	}
	
	if (0 >= self.password.text.length)
	{
		paramsReady = NO;
	}

	return paramsReady;
}

- (void) login:(id)sender
{
	if ([self checkParamsNotEmpty])
	{
		self.navigationItem.leftBarButtonItem.enabled = NO;

		@autoreleasepool 
		{
			NSString *accountString = self.account.text;
			NSString *passwordString = self.password.text;
			NSString *stringToHash = [NSString stringWithFormat:@"%@%@", [accountString lowercaseString], passwordString];
			NSData *dataToHash = [stringToHash dataUsingEncoding:NSUTF8StringEncoding];
			NSMutableString *finalHashedPwd = [[NSMutableString alloc] init]; 
			unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
			
			CC_SHA1([dataToHash bytes], [dataToHash length], hashBytes);
			
			for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i)
			{
				[finalHashedPwd appendFormat:@"%02x", hashBytes[i]];
			}
			
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:LOGIN_NATIVE] forKey:LOGIN_TYPE_KEY];
			[[NSUserDefaults standardUserDefaults] setObject:accountString forKey:NATIVE_ACCOUNT_KEY];
			[[NSUserDefaults standardUserDefaults] setObject:finalHashedPwd forKey:NATIVE_PASSWORD_KEY];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[LoginManager changeLoginUser];
			
			[finalHashedPwd release];
		}
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{	
	if ([self.account isFirstResponder])
	{
		[self.account resignFirstResponder];
		[self.password becomeFirstResponder];
	}
	else if ([self.password isFirstResponder])
	{
		[self.password resignFirstResponder];
	}

	return YES;
}

- (BOOL) textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string
{	
	return YES;
}

#pragma mark - action and interface

- (void) cleanLoginInfo
{
	self.password.text = @"";
	self.account.text = @"";
}

@end
