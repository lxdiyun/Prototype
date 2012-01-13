//
//  TagCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodTagCell.h"

#import "FourCountView.h"
#import "Util.h"

const static CGFloat FONT_SIZE = 15.0;
const static CGFloat FOUR_COUNT_HEIGTH = 10.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat ICON_SIZE = 20.0;

static CGFloat gs_four_count_x = 0;

@interface FoodTagCell ()
{
	NSDictionary *_foodDict;
	FourCountView *_fourCount;
	UILabel *_tagLabel;
	UIImageView *_icon;
}
@property (retain, nonatomic) FourCountView *fourCount;
@property (retain, nonatomic) UILabel *tagLabel;
@property (retain, nonatomic) UIImageView *icon;
@end

@implementation FoodTagCell

@synthesize foodDict = _foodDict;
@synthesize fourCount = _fourCount;
@synthesize tagLabel = _tagLabel;
@synthesize icon = _icon;

#pragma mark - draw cell

- (void) redrawIcon
{
	if (nil != self.icon)
	{
		[self.icon removeFromSuperview];
	}
	
	self.icon = [[[UIImageView alloc] initWithFrame:CGRectMake(PADING1 * PROPORTION(),
								   0, 
								   ICON_SIZE * PROPORTION(), 
								   ICON_SIZE * PROPORTION())]
		     autorelease];
	self.icon.image = [UIImage imageNamed:@"tagIcon.png"];
	self.icon.center = CGPointMake(self.icon.center.x, self.frame.size.height / 2);
	
	[self.contentView addSubview:self.icon];	
}


- (void) redrawFourCount
{
	if (nil != self.fourCount)
	{
		[self.fourCount removeFromSuperview];
	}
	
	if (nil != self.foodDict)
	{
		CGFloat width = [FourCountView calculateWidthForFood:self.foodDict];
		gs_four_count_x = self.contentView.frame.size.width - width - PADING2  *PROPORTION();
		
		self.fourCount = [[[FourCountView alloc] initWithFrame:CGRectMake(gs_four_count_x, 
										  0.0, 
										  width, 
										  FOUR_COUNT_HEIGTH * PROPORTION()) 
							   andFoodDict:self.foodDict] 
				  autorelease];
		self.fourCount.center = CGPointMake(self.fourCount.center.x , self.frame.size.height / 2);
		
		[self.contentView addSubview:self.fourCount];
	}
}

- (void) redrawTagLabel
{
	if (nil != self.tagLabel)
	{
		[self.tagLabel removeFromSuperview];
	}
	
	if (nil != self.foodDict)
	{
		CGFloat x = (PADING1 + ICON_SIZE ) * PROPORTION();
		CGFloat width = gs_four_count_x - x;
		uint8_t count = 0;
		NSMutableString *tagText = [[[NSMutableString alloc] init] autorelease];
		
		self.tagLabel = [[[UILabel alloc] initWithFrame:CGRectMake(x, 
									   0.0, 
									   width, 
									   FONT_SIZE * PROPORTION())] 
				 autorelease];
		self.tagLabel.center = CGPointMake(self.tagLabel.center.x , self.frame.size.height / 2);
		
		for (NSString *tag in [self.foodDict valueForKey:@"tags"]) 
		{
			if (2 <= count)
			{
				[tagText appendFormat:@"..."];
				break;
			}
			
			++count;
			[tagText appendFormat:@"%@ ", tag];
		}

		self.tagLabel.font = [UIFont systemFontOfSize:FONT_SIZE * PROPORTION()];
		self.tagLabel.text = tagText;

		[self.contentView addSubview:self.tagLabel];
	}
}


- (void) setFoodDict:(NSDictionary *)foodDict
{
	if (_foodDict == foodDict)
	{
		return;
	}
	
	[_foodDict release];
	
	_foodDict = [foodDict retain];
	
	if (nil != _foodDict)
	{
		@autoreleasepool
		{
			[self redrawIcon];
			[self redrawFourCount];
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
		self.contentView.backgroundColor = [Color whiteColor];
	}
	
	return self;
}

- (void) dealloc
{
	self.foodDict = nil;
	self.fourCount = nil;
	self.tagLabel = nil;
	self.icon = nil;
	
	[super dealloc];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}



@end
