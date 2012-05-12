//
//  DescriptionCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DescriptionCell.h"

#import <QuartzCore/QuartzCore.h>

#import "ImageV.h"
#import "Util.h"
#import "ProfileMananger.h"
#import "TriangleView.h"

const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 =  10.0; // padding from top virtical boder
const static CGFloat PADING4 = 10.0; // padding between element virtical and bottom border

@interface DescriptionCell () 
{
@private
	NSDictionary *_objectDict;
	UILabel *_description;
	TriangleView *_triangle;
}


@property (strong, nonatomic) UILabel *description;
@property (strong, nonatomic) TriangleView *triangle;
@end


@implementation DescriptionCell

@synthesize objectDict = _objectDict;
@synthesize description = _comment;
@synthesize triangle = _triangle;

# pragma mark - class method

+ (CGFloat) getHeightFor:(NSString *)description forWidth:(CGFloat)width
{
	CGFloat descHeight = 15.0;
	
	if ((nil != description) &&  (0 < description.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		descHeight = [description sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] 
				     constrainedToSize:constrained 
					 lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	return  descHeight;
}

+ (CGFloat) cellHeightForObject:(NSDictionary *)objectDict forCellWidth:(CGFloat)width
{
	NSString *description = [objectDict valueForKey:@"desc"];
	
	width = width - (PADING1 + PADING2);

	CGFloat cellHeight = [self getHeightFor:description forWidth:width];
	
	cellHeight += PADING4 + PADING3;
	
	return cellHeight;
}

#pragma mark - life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) 
	{
		self.contentView.backgroundColor = [Color whiteColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void) dealloc
{
	self.objectDict = nil;
	self.description = nil;
	self.triangle = nil;
	
	[super dealloc];
}

#pragma mark - draw cell

- (void) redrawDescription
{
	if (nil != self.description)
	{
		[self.description removeFromSuperview];
		self.description = nil;
	}
	
	NSString *description = [self.objectDict valueForKey:@"desc"];
	
	if ((nil != description) &&  (0 < description.length))
	{
		UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
		CGFloat X = PADING1;
		CGFloat Y = PADING3;
		CGFloat width = self.contentView.frame.size.width - (X + PADING2);
		CGFloat height = [[self class] getHeightFor:description forWidth:width];
		
		self.description = [[[UILabel alloc] 
				     initWithFrame:CGRectMake(X,
							      Y,
							      width,
							      height)] 
				    autorelease];
		
		self.description.numberOfLines = 0;
		self.description.font = font;
		self.description.backgroundColor = [UIColor clearColor];
		self.description.lineBreakMode = UILineBreakModeWordWrap;
		
		if (nil != self.objectDict)
		{
			self.description.text = [self.objectDict valueForKey:@"desc"];
		}
		
		[self.contentView addSubview:self.description];
	}
}

#pragma mark - message

- (void) setObjectDict:(NSDictionary *)objectDict
{
	if ([_objectDict isEqualToDictionary:objectDict])
	{
		return;
	}
	
	[_objectDict release];
	
	_objectDict = [objectDict retain];
	
	@autoreleasepool 
	{
		[self redrawDescription];
	}
}

@end
