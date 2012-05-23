//
//  InfoCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoCell.h"

#import "UserFollowingPage.h"
#import "UserFansPage.h"

@interface InfoCell ()
{
	NSDictionary *_user;
	UserFollowingPage *_followingPage;
	UserFansPage *_fansPage;
	id<ShowVCDelegate> _delegate;
}

@property (retain, nonatomic) UserFollowingPage *followingPage;
@property (retain, nonatomic) UserFansPage *fansPage;

@end

@implementation InfoCell

@synthesize user = _user;
@synthesize followingPage = _followingPage;
@synthesize fansPage = _fansPage;
@synthesize delegate = _delegate;

@synthesize avatar;
@synthesize name;
@synthesize place;
@synthesize intro;
@synthesize follow;
@synthesize fans;
@synthesize background;
@synthesize shadow;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(InfoCell)

- (void) resetupXIB:(InfoCell *)xibInstance
{
	xibInstance.user = self.user;
	xibInstance.followingPage = self.followingPage;
	xibInstance.delegate = self.delegate;
	
	[xibInstance initGUI];
}

+ (id) createFromXIB
{
	InfoCell *xibInstance = [[self loadInstanceFromNib] retain];
	
	[xibInstance initGUI];
	
	return [xibInstance autorelease];
}

#pragma mark - life circle

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if (self) 
	{
		@autoreleasepool 
		{
			self.followingPage = [[[UserFollowingPage alloc] init] autorelease];
			self.fansPage = [[[UserFansPage alloc] init] autorelease];
		}
	}
	
	return self;
}

- (void) dealloc 
{
	self.user = nil;
	
	[avatar release];
	[name release];
	[place release];
	[intro release];
	[follow release];
	[fans release];
	[background release];
	[shadow release];
	
	[super dealloc];
}

#pragma mark - object manage

- (void) setUser:(NSDictionary *)user
{
	if (CHECK_EQUAL(_user, user))
	{
		return;
	}
	
	[_user release];
	_user = [user retain];
	
	[self updateGUI];
}

#pragma mark - GUI

- (void) initGUI
{
	ROUND_RECT(self.follow.layer);
	ROUND_RECT(self.fans.layer);
	
	self.followingPage = [[[UserFollowingPage alloc] init] autorelease];
	self.fansPage = [[[UserFansPage alloc] init] autorelease];
	
	[self.shadow drawWithTop:[UIColor clearColor] 
			  bottom:[Color blackAlpha85]];
}

- (void) updateGUI
{
	if (nil != self.user)
	{
		@autoreleasepool 
		{
			self.name.text = [self.user valueForKey:@"nick"];
			self.place.text = [self.user valueForKey:@"city"];
			self.intro.text = [self.user valueForKey:@"intro"];
			self.avatar.picID = [self.user valueForKey:@"avatar"];
			self.background.picID = [self.user valueForKey:@"bg_pic"];
			NSString *fansTitle = [NSString stringWithFormat:@"%@ 粉丝", 
					       [self.user valueForKey:@"fans_count"]];
			[self.fans setTitle:fansTitle forState:UIControlStateNormal];
			NSString *folllowTitle = [NSString stringWithFormat:@"%@ 关注", 
						  [self.user valueForKey:@"following_count"]];
			[self.follow setTitle:folllowTitle forState:UIControlStateNormal];
		}
	}
}

#pragma mark - action

- (IBAction) showFollow:(id)sender 
{
	self.followingPage.userID = [[self.user valueForKey:@"id"] stringValue];
	
	[self.delegate showVC:self.followingPage];	
}

- (IBAction) showFans:(id)sender 
{
	self.fansPage.userID = [[self.user valueForKey:@"id"] stringValue];
	
	[self.delegate showVC:self.fansPage];
}

@end
