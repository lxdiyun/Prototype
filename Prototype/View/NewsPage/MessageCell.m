//
//  MessageCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"

#import "ProfileMananger.h"

@interface MessageCell ()
{
	NSDictionary *_conversationListDict;
}

@end

@implementation MessageCell

@synthesize conversationListDict = _conversationListDict;
@synthesize message;
@synthesize name;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(MessageCell);

- (void) resetupXIB:(MessageCell *)xibinstance
{
	[xibinstance initGUI];
}

+ (id) createFromXIB
{
	MessageCell *xibInstance = [[self loadInstanceFromNib] retain];
	
	[xibInstance initGUI];
	
	return [xibInstance autorelease];
}

#pragma mark - life circle

- (void) dealloc
{
	self.conversationListDict = nil;
	
	[message release];
	[name release];

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
	}
}

- (void) redrawMessage
{
	self.message.text = [self.conversationListDict valueForKey:@"msg"];
}

- (void) redrawUser:(NSDictionary *)userObject
{
	self.name.text = [userObject valueForKey:@"nick"];
}

#pragma mark - object manage

- (void) setConversationListDict:(NSDictionary *)conversationListDict
{
	if (CHECK_EQUAL(_conversationListDict ,conversationListDict))
	{
		return;
	}
	
	[_conversationListDict release];
	
	_conversationListDict = [conversationListDict retain];
	
	@autoreleasepool 
	{
		[self redrawMessage];
		
		[self requestUserProfile];
	}
}

- (void) requestUserProfile
{
	NSNumber * userID = [self.conversationListDict valueForKey:@"target"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			[self redrawUser:userProfile];
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
}


@end
