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
const static CGFloat PADING4 = 15.0; // padding between element virtical and bottom border
const static CGFloat TRIANGLE_HEIGHT = 10.0;
const static CGFloat TRIANGLE_WIDTH = 20.0;

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

+ (CGFloat) getDescriptionHeightFor:(NSDictionary *)commentDict forDescWidth:(CGFloat)width
{
	NSString *descString = [commentDict valueForKey:@"desc"];
	CGFloat descHeight = FONT_SIZE;
	
	if ((nil != descString) &&  (0 < descString.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		descHeight = [descString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] 
				    constrainedToSize:constrained 
					lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	return  descHeight;
}

+ (CGFloat) cellHeightForObject:(NSDictionary *)objectDict forCellWidth:(CGFloat)width
{
	width = width - (PADING1 + PADING2);

	CGFloat descHeight = [self getDescriptionHeightFor:objectDict forDescWidth:width];
	
	if (0 < [[objectDict valueForKey:@"comment_count"] intValue])
	{
		return descHeight + PADING4 + PADING3 + TRIANGLE_HEIGHT;
	}
	else 
	{
		return descHeight + PADING4 + PADING3;
	}
}

#pragma mark - life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) 
	{
		self.contentView.backgroundColor = [Color whiteColor];
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
- (void) redrawTriangleFrom:(CGFloat)fromHeight
{
	if (nil != self.triangle)
	{
		[self.triangle removeFromSuperview];
		self.triangle = nil;
	}
	
	if (0 < [[self.objectDict valueForKey:@"comment_count"] intValue])
	{
		CGFloat X = self.contentView.frame.size.width - TRIANGLE_WIDTH - PADING2;
		CGFloat Y = fromHeight;
		CGRect rect = CGRectMake(X, 
					 Y, 
					 TRIANGLE_WIDTH, 
					 TRIANGLE_HEIGHT);
		
		self.triangle = [[[TriangleView alloc] initWithFrame:rect 
							    andColor:[Color orangeColor]] 
				 autorelease];
		
		[self.contentView addSubview:self.triangle];
	}
}


- (void) redrawDescription
{
	if (nil != self.description)
	{
		[self.description removeFromSuperview];
	}
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
	CGFloat X = PADING1;
	CGFloat Y = PADING3;
	CGFloat width = self.contentView.frame.size.width - (X + PADING2);
	CGFloat height = [[self class] getDescriptionHeightFor:self.objectDict
						  forDescWidth:width];
	
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
	
	[self redrawTriangleFrom:(Y + height + PADING4)];
}

#pragma mark - message

- (void) setObjectDict:(NSDictionary *)objectDict
{
	if (_objectDict == objectDict)
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
