//
//  FoodDescCell.m
//  Prototype
//
//  Created by Adrian Lee on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodDescCell.h"

#import "Util.h"

const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 15.0; // padding from top virtical boder
const static CGFloat PADING4 = 28.0; // padding between element virtical and bottom border
static CGFloat LABEL_WIDTH = 300;

@interface FoodDescCell ()
{
	NSString *_description;
	UILabel *_descriptionLabel;
}

@property (retain) UILabel *descriptionLabel;

@end

@implementation FoodDescCell

@synthesize description = _description;
@synthesize descriptionLabel = _descriptionLabel;

+ (CGSize) labelSizeFor:(NSString *)description
{
	CGSize constrainedSize = CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX);
	
	return [description sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]  constrainedToSize:constrainedSize];	
}

+ (CGFloat) cellHeightForDesc:(NSString *)description
{
	CGFloat labelHeight = [self labelSizeFor:description].height;

	return labelHeight + PADING3 + PADING4;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
	    LABEL_WIDTH = LABEL_WIDTH * PROPORTION();
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
	self.description = nil;
	
	[super dealloc];
}

- (void) updateDescriptionLabel
{
	@autoreleasepool 
	{
		if (nil == self.descriptionLabel)
		{
			self.descriptionLabel = [[[UILabel alloc] init] autorelease];
			
			self.descriptionLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
			self.descriptionLabel.textColor = [Color lightyellow];
			self.descriptionLabel.backgroundColor = [UIColor clearColor];
			self.descriptionLabel.numberOfLines = 0;
			
			[self.contentView addSubview:self.descriptionLabel];
		}
		
		CGSize size = [[self class] labelSizeFor:self.description];
		self.descriptionLabel.frame = CGRectMake(PADING1, PADING3, size.width, size.height);
		self.descriptionLabel.text = self.description;
	}
}

- (void) setDescription:(NSString *)description
{
	if (_description != description)
	{
		[_description release];
		_description = [description retain];
		
		[self updateDescriptionLabel];
	}
}

@end
