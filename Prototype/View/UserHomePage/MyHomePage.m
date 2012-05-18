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

@interface MyHomePage ()
{

}

@end

@implementation MyHomePage

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		[self updateCurrentUser];
		
		[super initGUI];
	}
}

- (void) updateGUIWith:(NSDictionary *)user
{
	[super updateGUIWith:user];
	
	self.mapPage.saveWhenLeaved = YES;
	self.title = @"我的主页";
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

@end
