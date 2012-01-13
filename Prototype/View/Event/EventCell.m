//
//  EventCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"
#import "ImageV.h"
#import "Util.h"

@interface EventCell () 
{
	@private
		NSDictionary *_eventDict;
	UILabel *_title;
	UITextView *_desc;
	ImageV *_picImageV;
}

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UITextView *desc;
@property (strong, nonatomic) ImageV *picImageV;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize title = _title;
@synthesize desc = _desc;
@synthesize picImageV = _picImageV;

static CGFloat gs_title_height = 0;
static CGFloat gs_pic_size = 0;

- (void) redrawTitleLabel
{
	if (nil != self.title)
	{
		[self.title removeFromSuperview];
	}

	UIFont *font = [UIFont boldSystemFontOfSize:18.0 * PROPORTION()];

	gs_title_height = self.contentView.frame.size.width / 4;
	CGFloat X = 0;
	CGFloat Y = self.contentView.frame.size.height - gs_title_height;


	self.title = [[[UILabel alloc] init] autorelease];
	self.title.frame = CGRectMake(X,
				      Y,
				      self.contentView.frame.size.width,
				      gs_title_height);

	self.title.font = font;
	self.title.adjustsFontSizeToFitWidth = YES;
	self.title.backgroundColor = [UIColor clearColor];

	self.title.textColor = [Color whiteColor];

	[self.contentView addSubview:self.title];
}

- (void) redrawDescLabel
{
	if (nil != self.desc)
	{
		[self.desc removeFromSuperview];
	}

	UIFont *font = [UIFont boldSystemFontOfSize:15.0 * PROPORTION()];
	CGFloat descLabelWidth = self.contentView.frame.size.width - gs_pic_size - 10.0;
	CGFloat descLabelHeight= self.contentView.frame.size.height - gs_title_height - 10.0;

	self.desc = [[[UITextView alloc] 
		initWithFrame:CGRectMake(gs_pic_size + 10.0, 
					 gs_title_height + 10.0, 
					 descLabelWidth, 
					 descLabelHeight )] 
		autorelease];

	self.desc.font = font;
	self.desc.editable = NO;
	self.desc.contentOffset = CGPointZero;
	self.desc.scrollEnabled = YES;

	[self.contentView addSubview:self.desc];
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

- (void) redraw
{
	@autoreleasepool 
	{
		self.contentView.backgroundColor = [Color brownColor];
		[self redrawImageV];
		[self redrawTitleLabel];
		//[self redrawDescLabel];
	}
}

- (void) setEventDict:(NSDictionary *)eventDict
{
	if (_eventDict == eventDict)
	{
		return;
	}

	[_eventDict release];

	_eventDict = [eventDict retain];
	
	NSDictionary *objDict =  [self.eventDict valueForKey:@"obj"];

	self.picImageV.picID = [objDict valueForKey:@"pic"];

	self.title.text = [objDict valueForKey:@"name"];
	self.desc.text = [objDict valueForKey:@"desc"];
	
	if (nil != self.eventDict)
	{
		self.title.backgroundColor = [Color blackColorAlpha];
	}
	else
	{
		self.title.backgroundColor = [UIColor clearColor];
	}
}

- (void) dealloc
{
	self.eventDict = nil;
	self.title = nil;
	self.desc = nil;
	self.picImageV = nil;

	[super dealloc];
}


@end
