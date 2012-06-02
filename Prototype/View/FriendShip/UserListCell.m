//
//  UserListCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserListCell.h"

#import "ProfileMananger.h"

@interface UserListCell ()
{
	NSNumber *_userID;
}

@end

@implementation UserListCell

@synthesize userID = _userID;
@synthesize image;
@synthesize name;
@synthesize desc;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(UserListCell, 0);

- (void) resetupXIB:(UserListCell *)xibinstance
{
	[xibinstance initGUI];
}

#pragma mark - life circle

- (void) dealloc 
{
	[image release];
	[name release];
	[desc release];
	
	self.userID = nil;

	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		UIView* background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		CELL_BORDER(background.layer);
		self.backgroundView = background;
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
}

- (void) drawUser:(NSDictionary *)user
{
	self.name.text = [user valueForKey:@"nick"];
	self.image.picID = [user valueForKey:@"avatar"];
	self.desc.text = [user valueForKey:@"intro"];
}

#pragma mark - object manage

- (void) setUserID:(NSNumber *)userID
{
	if (CHECK_EQUAL(userID, _userID))
	{
		return;
	}
	
	[_userID release];
	_userID = [userID retain];
	
	self.name.text = nil;
	self.image.picID = nil;
	self.desc.text = nil;

	[self requestUser];
}

- (void) requestUser
{

	NSDictionary * userObject = [ProfileMananger getObjectWithNumberID:self.userID];
	
	if (nil != userObject)
	{
		[self drawUser:userObject];
	}
	else
	{
		[ProfileMananger requestObjectWithNumberID:self.userID 
						andHandler:@selector(requestUser) 
						 andTarget:self];
	}

}

@end
