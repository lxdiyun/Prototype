//
//  TagCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodTagCell.h"

#import "Util.h"

const static CGFloat FONT_SIZE = 12.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 15.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 =  10.0; // padding from top virtical boder
const static CGFloat PADING4 = 10.0; // padding between element virtical and bottom border
const static CGFloat ICON_SIZE = 20.0;

@interface FoodTagCell ()
{
	NSDictionary *_foodObject;
	UILabel *_tagLabel;
	UIImageView *_icon;
}

@property (retain, nonatomic) UILabel *tagLabel;
@property (retain, nonatomic) UIImageView *icon;
@end

@implementation FoodTagCell

@synthesize foodObject = _foodObject;
@synthesize tagLabel = _tagLabel;
@synthesize icon = _icon;

#pragma mark - class interface

+ (CGFloat) getHeightFor:(NSString *)tags forWidth:(CGFloat)width
{
	CGFloat height = 0;
	
	if ((nil != tags) && (0 < tags.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		
		height = [tags sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] 
				 constrainedToSize:constrained 
				     lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	return  height;
}

+ (CGFloat) cellHeightForObject:(NSDictionary *)objectDict forCellWidth:(CGFloat)width
{
	@autoreleasepool 
	{
		NSMutableString *tagText = [[[NSMutableString alloc] init] autorelease];
		
		for (NSString *tag in [objectDict valueForKey:@"tags"]) 
		{
			[tagText appendFormat:@"%@     ", tag];
		}
		
		width -= (2 * PADING1 + PADING2 + ICON_SIZE);
		
		CGFloat cellHeight = [self getHeightFor:tagText forWidth:width];
		
		if (ICON_SIZE < cellHeight)
		{
			cellHeight += PADING3 + ICON_SIZE / 2 - FONT_SIZE / 2 + PADING4;
		}
		else 
		{
			cellHeight = PADING3 + ICON_SIZE + PADING4;
		}
		
		return cellHeight;
	}
}

#pragma mark - draw cell

- (void) redrawIcon
{
	if (nil != self.icon)
	{
		[self.icon removeFromSuperview];
	}
	
	self.icon = [[[UIImageView alloc] initWithFrame:CGRectMake(PADING1,
								   PADING3, 
								   ICON_SIZE, 
								   ICON_SIZE)]
		     autorelease];
	self.icon.image = [UIImage imageNamed:@"tagIcon.png"];
	
	[self.contentView addSubview:self.icon];	
}

- (void) redrawTagLabel
{
	if (nil != self.tagLabel)
	{
		[self.tagLabel removeFromSuperview];
	}
	
	if (nil != self.foodObject)
	{
		CGFloat x = (PADING1 + ICON_SIZE + PADING1);
		CGFloat y = PADING1 + ICON_SIZE / 2 - FONT_SIZE / 2;
		CGFloat width = self.contentView.frame.size.width - x - PADING2;
		NSMutableString *tagText = [[[NSMutableString alloc] init] autorelease];
		
		self.tagLabel = [[[UILabel alloc] initWithFrame:CGRectMake(x, 
									   y, 
									   width, 
									   FONT_SIZE)] 
				 autorelease];
		
		for (NSString *tag in [self.foodObject valueForKey:@"tags"]) 
		{
			[tagText appendFormat:@"%@     ", tag];
		}

		self.tagLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
		self.tagLabel.textColor = [Color tastyColor];
		self.tagLabel.backgroundColor = [UIColor clearColor];
		self.tagLabel.text = tagText;
		self.tagLabel.numberOfLines = 0;
		self.tagLabel.lineBreakMode = UILineBreakModeWordWrap;
		[self.tagLabel sizeToFit];

		[self.contentView addSubview:self.tagLabel];
	}
}


- (void) setFoodObject:(NSDictionary *)foodObject
{
	if ([_foodObject isEqualToDictionary:foodObject])
	{
		return;
	}
	
	[_foodObject release];
	
	_foodObject = [foodObject retain];
	
	if (nil != _foodObject)
	{
		@autoreleasepool
		{
			[self redrawIcon];
			[self redrawTagLabel];
		}
	}
}

#pragma mark life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) 
	{
		self.contentView.backgroundColor = [Color grey1Color];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return self;
}

- (void) dealloc
{
	self.foodObject = nil;
	self.tagLabel = nil;
	self.icon = nil;
	
	[super dealloc];
}

@end
