//
//  NoticeCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoticeCell.h"

@interface NoticeCell ()
{
	NSDictionary *_noticeObject;
	
}

@end

@implementation NoticeCell

@synthesize image;
@synthesize message;
@synthesize accessory;
@synthesize noticeObject = _noticeObject;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(NoticeCell);

- (void) resetupXIB:(NoticeCell *)xibinstance
{
	[xibinstance initGUI];
}

+ (id) createFromXIB
{
	NoticeCell *xibInstance = [[self loadInstanceFromNib] retain];
	
	[xibInstance initGUI];
	
	return [xibInstance autorelease];
}



#pragma mark - life circle

- (void) dealloc 
{
	self.noticeObject = nil;
	
	[image release];
	[message release];

	[accessory release];
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

- (void) updateGUI
{
	self.image.picID = [self.noticeObject valueForKey:@"img"];
	self.message.text = [self.noticeObject valueForKey:@"msg"];
	NSString *type = [self.noticeObject valueForKey:@"msg_type"];
	
	if ([[self.noticeObject valueForKey:@"is_read"] boolValue])
	{
		self.message.textColor = [Color grey2];
		
		if (CHECK_EQUAL(type, @"follow"))
		{
			self.accessory.image = [UIImage  imageNamed: @"Notice_follow_read.png"];
		}
		else if (CHECK_EQUAL(type, @"comment"))
		{
			self.accessory.image = [UIImage  imageNamed: @"Notice_comment_read.png"];
		}
		else 
		{
			self.accessory.image = nil;
		}
	}
	else 
	{
		self.message.textColor = [Color tasty];
		
		if (CHECK_EQUAL(type, @"follow"))
		{
			self.accessory.image = [UIImage  imageNamed: @"Notice_follow_unread.png"];
		}
		else if (CHECK_EQUAL(type, @"comment"))
		{
			self.accessory.image = [UIImage  imageNamed: @"Notice_comment_unread.png"];
		}
		else 
		{
			self.accessory.image = nil;
		}
	}
}

#pragma mark - object manage

- (void) setNoticeObject:(NSDictionary *)noticeObject
{
	if (CHECK_EQUAL(_noticeObject, noticeObject))
	{
		return;
	}
	
	[_noticeObject release];
	_noticeObject = [noticeObject retain];
	
	[self updateGUI];
}

@end
