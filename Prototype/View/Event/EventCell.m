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
#import "Alert.h"

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
	UILabel *_name;
	Alert *_alert;
}

@property (strong, nonatomic) ImageV *picImageV;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) Alert *alert;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize picImageV = _picImageV;
@synthesize name = _name;
@synthesize alert = _alert;

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
	self.picImageV.contentMode = UIViewContentModeScaleAspectFit;

	[self.contentView addSubview:self.picImageV];
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
	[self.alert dismiss];

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
	if (nil != self.eventDict)
	{
		self.picImageV.image = [self.eventDict valueForKey:@"pic"];
		self.name.text = [NSString stringWithFormat:@" %@", [self.eventDict valueForKey:@"name"]];
		self.picImageV.hidden = NO;
		self.name.hidden = NO;
		[self.alert showInCenter:self.picImageV];
	}
	else 
	{
		self.picImageV.hidden = YES;
		self.name.hidden = YES;
	}
}

#pragma mark - object manage

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
		
		if (nil == self.alert)
		{
			self.alert = [Alert createFromXIB];

			self.alert.messageText = @"上传中";	
		}
	}
	
	return self;
}

- (void) dealloc
{
	self.eventDict = nil;
	self.picImageV = nil;
	self.alert = nil;

	[super dealloc];
}


@end
