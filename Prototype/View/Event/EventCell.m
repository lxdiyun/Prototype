//
//  EventCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"

#import <QuartzCore/QuartzCore.h>

#import "ImageV.h"
#import "Util.h"
#import "ProfileMananger.h"
#import "EventManager.h"

const static CGFloat AVATOR_SIZE = 44.0;
const static CGFloat AVATOR_BORDER = 3.0;
const static CGFloat NAME_HEIGHT = 30.0;
const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 15.0; // padding from top virtical boder
const static CGFloat PADING4 = 10.0; // padding between element virtical and bottom border

@interface EventCell () 
{

	NSDictionary *_eventDict;
	ImageV *_picImageV;
	ImageV *_avator;
	UILabel *_name;
}

@property (strong, nonatomic) ImageV *picImageV;
@property (strong, nonatomic) ImageV *avator;
@property (strong, nonatomic) UILabel *name;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize picImageV = _picImageV;
@synthesize avator = _avator;
@synthesize name = _name;

static CGFloat gs_pic_size = 0;

#pragma mark - GUI

- (void) redrawName
{
	if (nil != self.name)
	{
		[self.name removeFromSuperview];
	}
	
	
	CGFloat X = 0;
	CGFloat height = NAME_HEIGHT;
	CGFloat Y = gs_pic_size - height;
	CGFloat width = gs_pic_size;
	
	self.name = [[[UILabel alloc] initWithFrame:CGRectMake(X, Y, width, height)] 
		     autorelease];
	
	self.name.font = [UIFont systemFontOfSize:FONT_SIZE];
	self.name.backgroundColor = [Color blackAlpha50];
	self.name.textColor = [UIColor whiteColor];
	self.name.textAlignment = UITextAlignmentLeft;
	self.name.numberOfLines = 0;
	self.name.hidden = YES;
	
	[self.contentView addSubview:self.name];
}

- (void) redrawImageV
{
	if (nil != self.picImageV)
	{
		[self.picImageV removeFromSuperview];
	}

	gs_pic_size = self.contentView.frame.size.height;

	self.picImageV = [[[ImageV alloc] initWithFrame:CGRectMake(0.0, 
								   0.0, 
								   gs_pic_size, 
								   gs_pic_size)] 
		autorelease];

	[self.contentView addSubview:self.picImageV];
}

- (void) redrawAvator
{
	if (nil != self.avator)
	{
		[self.avator removeFromSuperview];
	}
	
	CGFloat X = PADING1 * PROPORTION();
	CGFloat Y = gs_pic_size - (PADING4 + AVATOR_SIZE) * PROPORTION();
	CGFloat width = AVATOR_SIZE * PROPORTION();
	CGFloat height = AVATOR_SIZE * PROPORTION();
	
	self.avator = [[[ImageV alloc] initWithFrame:CGRectMake(X, 
								Y, 
								width, 
								height)] 
			  autorelease];
	
	[self.contentView addSubview:self.avator];
}

- (void) redraw
{
	@autoreleasepool 
	{
		self.contentView.backgroundColor = [UIColor clearColor];
		[self redrawImageV];
		[self redrawName];
	}
}

- (void) updateNormalEvent
{
	NSDictionary *objDict = [self.eventDict valueForKey:@"obj"];
	self.alpha = 1.0;
	
	if (nil != objDict) 
	{
		self.picImageV.picID = [objDict valueForKey:@"pic"];
		self.name.text = [NSString stringWithFormat:@" %@", [objDict valueForKey:@"name"]]; 
		self.picImageV.hidden = NO;
		self.name.hidden = NO;
	}
	else 
	{
		self.picImageV.hidden = YES;
		self.name.hidden = YES;
	}
}

- (void) updateTaskEvent
{
	self.alpha = 0.8;

	if (nil != self.eventDict)
	{
		self.picImageV.image = [self.eventDict valueForKey:@"pic"];
		self.name.text = [NSString stringWithFormat:@" %@", [self.eventDict valueForKey:@"name"]];
		self.picImageV.hidden = NO;
		self.name.hidden = NO;
	}
	else 
	{
		self.picImageV.hidden = YES;
		self.name.hidden = YES;
	}
}

#pragma mark - object manage

- (void) requestUserProfile
{
	NSNumber * userID = [[self.eventDict valueForKey:@"obj"] valueForKey:@"user"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.avator.picID = [userProfile valueForKey:@"avatar"];
			[self.avator.layer setBorderColor:[[Color blackAlpha50] CGColor]];
			[self.avator.layer setBorderWidth: AVATOR_BORDER * PROPORTION()];
			
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
	else
	{
		if (nil != self.avator)
		{
			self.avator.picID = nil;
			[self.avator.layer setBorderColor:[[UIColor clearColor] CGColor]];
			[self.avator.layer setBorderWidth: 0.0];
		}
	}
}

- (void) setEventDict:(NSDictionary *)eventDict
{
	if (CHECK_EQUAL(_eventDict , eventDict))
	{
		return;
	}

	[_eventDict release];

	_eventDict = [eventDict retain];
	
	NSString *eventID = [self.eventDict valueForKey:@"id"];
	
	if (CHECK_STRING(eventID))
	{
		if ([eventID hasPrefix:EVENT_TASK_ID_PREFIX])
		{
			[self updateTaskEvent];
		}
	}
	else 
	{
		[self updateNormalEvent];
	}
	
}

#pragma mark - life cirlce

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (nil != self)
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return self;
}

- (void) dealloc
{
	self.eventDict = nil;
	self.picImageV = nil;
	self.avator = nil;
	
	[self.avator.layer setBorderWidth: 0.0];

	[super dealloc];
}


@end
