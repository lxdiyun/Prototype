//
//  MyHomePage.m
//  Prototype
//
//  Created by Adrian Lee on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyHomePage.h"

#import "MyInfoCell.h"
#import "LoginManager.h"
#import "BackgroundSelectPage.h"

@interface MyHomePage () <SelectBackgroundDelegate>
{
	MyInfoCell *_info;
	BackgroundSelectPage *_backgroundSelectPage;
}

@property (strong, nonatomic) MyInfoCell *info;
@property (strong, nonatomic) BackgroundSelectPage *backgroundSelectPage;

@end

@implementation MyHomePage

@synthesize info = _info;
@synthesize backgroundSelectPage = _backgroundSelectPage;

#pragma mark - lifce circle

- (void) dealloc
{
	self.info = nil;
	self.backgroundSelectPage = nil;

	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		[super initGUI];

		[self updateCurrentUser];

		if (nil == self.info)
		{
			self.info = [MyInfoCell createFromXIB];
			self.info.delegate = self;
		}
		
		if (nil == self.backgroundSelectPage)
		{
			self.backgroundSelectPage = [[[BackgroundSelectPage alloc] init] autorelease];
		}
		
		self.title = @"我的主页";
	}
}

- (void) updateGUIWith:(NSDictionary *)user
{
	[super updateGUIWith:user];
	
	self.info.user = user;
	
	self.mapPage.saveWhenLeaved = YES;
	
}

- (InfoCell *) getInfoCell
{
	return self.info;
}

#pragma mark - object manager

- (void) updateCurrentUser
{
	NSNumber *currentUserID = GET_USER_ID();
	
	if (nil != currentUserID)
	{
		self.userID = currentUserID;
		
		[self requestUserInfo];
	}
	else 
	{
		[LoginManager requestWithHandler:@selector(updateCurrentUser) andTarget:self];
	}
	
}

#pragma mark - SelectBackgroundDelegate

- (void) selectBackground
{
	[self.navigationController pushViewController:self.backgroundSelectPage animated:YES];
}

@end
