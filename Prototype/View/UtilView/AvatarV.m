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
#import "UserHomePage.h"
#import "MyHomePage.h"
#import "AppDelegate.h"

@interface AvatarV ()
{
	NSDictionary *_user;
	id<ShowVCDelegate> _delegate;
	UserHomePage *_userHomePage;
	MyHomePage *_myHomePage;
}

@property (retain, nonatomic) UserHomePage *userHomePage;
@property (retain, nonatomic) MyHomePage *myHomePage;

@end

@implementation AvatarV

@synthesize user = _user;
@synthesize delegate = _delegate;
@synthesize userHomePage = _userHomePage;
@synthesize myHomePage = _myHomePage;

@synthesize button;
@synthesize avator;

#pragma mark - xib cutsom object

DEFINE_CUSTOM_XIB(AvatarV, 0);

- (void) resetupXIB:(AvatarV *)xibInstance
{
	xibInstance.frame = self.frame;
	xibInstance.autoresizingMask = self.autoresizingMask;
	xibInstance.delegate = self.delegate;
}

+ (id) createFromXibWithFrame:(CGRect)frame
{
	AvatarV *xibInstance = [[self loadInstanceFromNib] retain];
	
	xibInstance.frame = frame;
	
	return [xibInstance autorelease];
}

#pragma mark - life circle

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			self.userHomePage = [[[UserHomePage alloc] init] autorelease];
			self.myHomePage = [[[MyHomePage alloc] init] autorelease];
		}
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
	self.userHomePage = nil;

	[button release];
	[avator release];
	[super dealloc];
}

#pragma mark - action

- (IBAction) tap:(id)sender 
{
	NSNumber *userID = [self.user valueForKey:@"id"];
	
	if (nil != userID)
	{
		self.userHomePage.userID = userID;
		[self.userHomePage resetGUI];
		
		[self.delegate showVC:self.userHomePage];
	}
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

- (void) initGUI
{
	
}

- (void) updateGUI
{
	NSNumber *picID = [self.user valueForKey:@"avatar"];
	
	self.avator.picID = picID;
}


@end
