//
//  EventCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"
#import "ImageV.h"

@interface EventCell () 
{
@private
	NSDictionary *_eventDict;
	UILabel *_title;
	UITextView *_desc;
	ImageV *_picImageV;
}

@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UITextView *desc;
@property (retain, nonatomic) ImageV *picImageV;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize title = _title;
@synthesize desc = _desc;
@synthesize picImageV = _picImageV;

static CGFloat gs_title_heigth = 0;
static CGFloat gs_pic_size = 0;

- (void) redrawTitleLabel
{
	if (nil != self.title)
	{
		[self.title removeFromSuperview];
	}
	
	UIFont *font = [UIFont boldSystemFontOfSize:18.0];
	CGFloat frameHeightHalf = self.contentView.frame.size.height/2;
	NSString *text = @"temp_text";
	CGSize bestSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(9999, frameHeightHalf) lineBreakMode: UILineBreakModeWordWrap];
	
	gs_title_heigth = bestSize.height;
	
	self.title = [[[UILabel alloc] init] autorelease];
	self.title.frame = CGRectMake(gs_pic_size + 10.0, 
				      5.0, 
				      self.contentView.frame.size.width - gs_pic_size - 10.0,
				      gs_title_heigth);

	self.title.font = font;
	self.title.adjustsFontSizeToFitWidth = YES;
	
	[self.contentView addSubview:self.title];
}

- (void) redrawDescLabel
{
	if (nil != self.desc)
	{
		[self.desc removeFromSuperview];
	}
	
	UIFont *font = [UIFont boldSystemFontOfSize:15.0];
	CGFloat descLabelWidth = self.contentView.frame.size.width - gs_pic_size - 10.0;
	CGFloat descLabelHeight= self.contentView.frame.size.height - gs_title_heigth - 10.0;
	
	self.desc = [[[UITextView alloc] 
		      initWithFrame:CGRectMake(gs_pic_size + 10.0, 
					       gs_title_heigth + 10.0, 
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
	
	gs_pic_size = self.contentView.frame.size.height - 10.0;

	self.picImageV = [[[ImageV alloc] initWithFrame:CGRectMake(5.0, 
								   5.0, 
								   gs_pic_size, 
								   gs_pic_size)] 
			  autorelease];
	
	[self.contentView addSubview:self.picImageV];
}

- (void) redraw
{
	@autoreleasepool 
	{
		[self redrawImageV];
		[self redrawTitleLabel];
		[self redrawDescLabel];
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
	
	self.picImageV.picDict = [self.eventDict valueForKey:@"pic"];
	
	self.title.text = [self.eventDict valueForKey:@"name"];
	self.desc.text = [self.eventDict valueForKey:@"desc"];
	

	
	// [self redraw];
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
