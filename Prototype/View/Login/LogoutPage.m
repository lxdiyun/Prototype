//
//  LogoutPage.m
//  Prototype
//
//  Created by Adrian Lee on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogoutPage.h"
#import "LoginManager.h"

@interface LogoutPage () <UIAlertViewDelegate>
{
	UIAlertView *_alert;
}

@property (strong) UIAlertView *alert;

@end

@implementation LogoutPage

@synthesize alert = _alert;

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self confirmLogout];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void) dealloc
{
	self.alert = nil;
	[super dealloc];
}

- (void) confirmLogout
{
	if (nil == self.alert)
	{
		@autoreleasepool 
		{
			UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
			
			alert.title = @"确认注销";
			alert.message = @"主销后将清空本地缓存";
			
			[alert addButtonWithTitle:@"取消"];
			[alert addButtonWithTitle:@"好滴"];
			alert.delegate = self;
			self.alert = alert;
		}
	}

	[self.alert show];	
}

- (void) logout
{
	[LoginManager logoutCurrentUser];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (1 == buttonIndex)
	{
		[self logout];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
