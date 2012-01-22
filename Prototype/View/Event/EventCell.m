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

const static CGFloat AVATOR_SIZE = 44;
const static CGFloat AVATOR_BORDER = 3.0;
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
}

@property (strong, nonatomic) ImageV *picImageV;
@property (strong, nonatomic) ImageV *avator;
@end

@implementation EventCell

@synthesize eventDict = _eventDict;
@synthesize picImageV = _picImageV;
@synthesize avator = _avator;

static CGFloat gs_pic_size = 0;

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
		self.contentView.backgroundColor = [Color brownColor];
		[self redrawImageV];
		[self redrawAvator];
	}
}

#pragma mark - message

- (void) requestUserProfile
{
	NSNumber * userID = [[self.eventDict valueForKey:@"obj"] valueForKey:@"user"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.avator.picID = [userProfile valueForKey:@"avatar"];
			[self.avator.layer setBorderColor:[[Color blackColorAlpha] CGColor]];
			[self.avator.layer setBorderWidth: AVATOR_BORDER * PROPORTION()];
			
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
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

	[self requestUserProfile];
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
