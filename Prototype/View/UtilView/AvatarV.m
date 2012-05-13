//
//  AvatarV.m
//  Prototype
//
//  Created by Adrian Lee on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvatarV.h"

#import "Util.h"
#import "ImageManager.h"
#import "UserInfoPage.h"

@interface AvatarV ()
{
	NSDictionary *_user;
	id<ShowVCDelegate> _delegate;
	UserInfoPage *_userInfoPage;
}

@property (retain, nonatomic) UserInfoPage *userInfoPage;

@end

@implementation AvatarV

@synthesize user = _user;
@synthesize delegate = _delegate;
@synthesize userInfoPage = _userInfoPage;
@synthesize button;
@synthesize avator;

#pragma mark - xib cutsom object

DEFINE_CUSTOM_XIB(AvatarV);

- (void) resetupXIB:(AvatarV *)xibInstance
{
	xibInstance.frame = self.frame;
	xibInstance.autoresizingMask = self.autoresizingMask;
	xibInstance.delegate = self.delegate;
}

#pragma mark - life circle

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			self.userInfoPage = [[[UserInfoPage alloc] init] autorelease];
		}
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [[AvatarV loadInstanceFromNib] retain];
	
	if (nil != self)
	{
		self.frame = frame;
	}

	return self;
} 


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
	self.user = nil;
	self.userInfoPage = nil;

	[button release];
	[avator release];
	[super dealloc];
}

#pragma mark - action

- (IBAction) tap:(id)sender 
{
	[self.delegate showVC:self.userInfoPage];
}

#pragma mark - manager object

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

- (void) updateGUI
{
	NSNumber *picID = [self.user valueForKey:@"avatar"];
	
	self.avator.picID = picID;
}


@end
