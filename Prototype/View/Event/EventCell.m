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
	UILabel *_desc;
	ImageV *_picImageV;
}

@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UILabel *desc;
@property (retain, nonatomic) ImageV *picImageV;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize title = _title;
@synthesize desc = _desc;
@synthesize picImageV = _picImageV;

- (void) redrawTitleLabel
{
	if (nil != self.title)
	{
		[self.title removeFromSuperview];
	}
	
	CGFloat picSize = self.contentView.frame.size.height - 10.0;
	CGFloat frameHeightHalf = self.contentView.frame.size.height/2;
	
	self.title = [[[UILabel alloc] 
		       initWithFrame:CGRectMake(picSize + 10.0, 
						5.0, 
						self.contentView.frame.size.width - picSize - 10.0,
						frameHeightHalf - 10.0)] 
		      autorelease];
	
	

	self.title.font = [UIFont boldSystemFontOfSize:18.0];
	self.title.adjustsFontSizeToFitWidth = YES;
	self.title.highlightedTextColor = [UIColor whiteColor];
	[self.contentView addSubview:self.title];
}

- (void) redrawDescLabel
{
	if (nil != self.desc)
	{
		[self.desc removeFromSuperview];
	}
	
	CGFloat picSize = self.contentView.frame.size.height - 10.0;
	CGFloat frameHeightHalf = self.contentView.frame.size.height/2;
	
	self.desc = [[[UILabel alloc] 
		      initWithFrame:CGRectMake(picSize + 10.0, 
					       frameHeightHalf + 5.0, 
					       self.contentView.frame.size.width - picSize - 10.0, 
					       frameHeightHalf - 10.0)] 
		     autorelease];
	
	self.desc.font = [UIFont boldSystemFontOfSize:15.0];
	self.desc.adjustsFontSizeToFitWidth = NO;
	self.desc.highlightedTextColor = [UIColor whiteColor];
	[self.contentView addSubview:self.desc];
}

- (void) redrawImageV
{
	if (nil != self.picImageV)
	{
		[self.picImageV removeFromSuperview];
	}
	
	CGFloat picSize = self.contentView.frame.size.height - 10.0;

	self.picImageV = [[[ImageV alloc] initWithFrame:CGRectMake(5.0, 
								   5.0, 
								   picSize, 
								   picSize)] 
			  autorelease];
	
	[self.contentView addSubview:self.picImageV];
}

- (void) redraw
{
	@autoreleasepool 
	{
		[self redrawTitleLabel];
		[self redrawDescLabel];
		[self redrawImageV];
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
