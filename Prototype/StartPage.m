//
//  StartPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StartPage.h"
#import "UserInfoPage.h"
#import "EventPage.h"

@interface StartPage ()
{
@private
	UserInfoPage *_userInfoView;
	EventPage *_eventView;
}
@property (strong) UserInfoPage *userInfoView;
@property (strong) EventPage *eventView;
@end

@implementation StartPage

@synthesize userInfoView = _userInfoView;
@synthesize eventView = _eventView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Prototype Test";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setUserInfoView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - action

- (IBAction)showUserInfo:(id)sender 
{

	@autoreleasepool 
	{
		if (nil == self.userInfoView)
		{
			UserInfoPage *userInfoView = [[UserInfoPage alloc] init];
			[self setUserInfoView:userInfoView];
			[userInfoView release];
		}

		[self.navigationController pushViewController:self.userInfoView animated:YES];
	}
}

- (IBAction)showEvent:(id)sender {
	@autoreleasepool 
	{
		if (nil == self.eventView)
		{
			EventPage *eventView = [[EventPage alloc] init];
			self.eventView = eventView;
			[eventView release];
		}
		
		[self.navigationController pushViewController:self.eventView animated:YES];
	}
}

#pragma mark - memory mamangement

- (void)dealloc 
{
	self.userInfoView = nil;
	self.eventView = nil;
	
	[super dealloc];
}
@end
