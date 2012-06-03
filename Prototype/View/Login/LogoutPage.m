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

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.hidesBackButton = YES;
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
			alert.message = @"";
			
			[alert addButtonWithTitle:@"Cancel"];
			[alert addButtonWithTitle:@"OK"];
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
	if (self.navigationController.topViewController == self)
	{
		[self.navigationController popViewControllerAnimated:NO];
	}

	if (1 == buttonIndex)
	{
		[self logout];
	}
}

@end
