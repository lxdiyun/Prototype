//
//  FoodImageCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodImageCell.h"

@interface FoodImageCell () 
{
	ImageV *_foodImage;
}
@end

@implementation FoodImageCell

@synthesize foodImage = _foodImage;

static CGFloat gs_food_image_size = 0;

- (void) redrawImageV
{
	if (nil != self.foodImage)
	{
		[self.foodImage removeFromSuperview];
	}
	
	gs_food_image_size = [UIScreen mainScreen].bounds.size.width;
	
	self.foodImage = [[[ImageV alloc] initWithFrame:CGRectMake(0.0, 
								   0.0, 
								   gs_food_image_size, 
								   gs_food_image_size)] 
			  autorelease];
	
	[self.contentView addSubview:self.foodImage];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (nil != self)
	{
		[self redrawImageV];
	}
	
	return self;
}


- (void) dealloc 
{
	self.foodImage = nil;
	[super dealloc];
}
@end
