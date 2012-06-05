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
#import "PhotoSelector.h"
#import "ImageManager.h"
#import "ProfileMananger.h"

@interface MyHomePage () <MyInfoDelegate, PhototSelectorDelegate>
{
	MyInfoCell *_info;
	BackgroundSelectPage *_backgroundSelectPage;
	PhotoSelector *_avatarSelector;
}

@property (strong, nonatomic) MyInfoCell *info;
@property (strong, nonatomic) BackgroundSelectPage *backgroundSelectPage;
@property (strong, nonatomic) PhotoSelector *avatarSelector;

@end

@implementation MyHomePage

@synthesize info = _info;
@synthesize backgroundSelectPage = _backgroundSelectPage;
@synthesize avatarSelector = _avatarSelector;

#pragma mark - lifce circle

- (void) dealloc
{
	self.info = nil;
	self.backgroundSelectPage = nil;
	self.avatarSelector = nil;

	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		[super initGUI];

		if (nil == self.info)
		{
			self.info = [MyInfoCell createFromXIB];
			self.info.delegate = self;
		}
		
		if (nil == self.backgroundSelectPage)
		{
			self.backgroundSelectPage = [[[BackgroundSelectPage alloc] init] autorelease];
		}
		
		if (nil == self.avatarSelector)
		{
			self.avatarSelector = [[[PhotoSelector alloc] init] autorelease];
			self.avatarSelector.delegate = self;
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

- (void) viewWillAppearRequest
{
	[self updateCurrentUser];
	
	[super viewWillAppearRequest];
}

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

- (void) setAvatar:(NSNumber *)picID
{
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:picID, @"avatar", nil];
	
	[ProfileMananger updateProfile:params withHandler:@selector(updateCurrentUser) andTarget:self];
	
	[params release];
}

#pragma mark - SelectBackgroundDelegate

- (void) selectBackground
{
	PUSH_VC(self.navigationController, self.backgroundSelectPage, YES);
}

- (void) selectAvatar
{
	[self.avatarSelector.actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
}

#pragma mark - PhototSelectorDelegate


#pragma mark - ShowModalVCDelegate

- (void) showModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self presentModalViewController:vc animated:animation];
}

- (void) dismissModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self dismissModalViewControllerAnimated:animation];
}

- (void) didSelectPhotoWithSelector:(PhotoSelector *)selector
{
	[self dismissModalViewControllerAnimated:YES];

	[ImageManager createImage:selector.selectedImage 
		      withHandler:@selector(avatarUploadCompleted:)
			andTarget:self];
	
	selector.selectedImage = nil;
	
	self.info.avatar.picID = nil;
	[self.info.avatar startIndicator];
}

#pragma mark - action

- (void) avatarUploadCompleted:(id)result
{
	NSNumber *picID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	if (nil != picID)
	{
		[self setAvatar:picID];
	}
}

@end
