//
//  FoodImageCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodImageCell.h"

#import "Util.h"

@interface FoodImageCell () 
{
	ImageV *_foodImage;
	FoodScore *_score;
}
@end

@implementation FoodImageCell

@synthesize foodImage = _foodImage;
@synthesize score = _score;

static CGFloat gs_food_image_size = 0;

- (void) redrawImageV
{
	if (nil != self.foodImage)
	{
		[self.foodImage removeFromSuperview];
	}

	gs_food_image_size = self.frame.size.width;
	
	self.foodImage = [[[ImageV alloc] initWithFrame:CGRectMake(0.0, 
								   0.0, 
								   gs_food_image_size, 
								   gs_food_image_size)] 
			  autorelease];
	
	self.contentView.clipsToBounds = YES;
	
	[self.contentView addSubview:self.foodImage];
}


- (void) redrawScore
{
	if (nil != self.score)
	{
		[self.score.view removeFromSuperview];
	}
	
	self.score = [[[FoodScore alloc] init] autorelease];
	
	CGPoint scoreCenter = CGPointMake(gs_food_image_size / 2, 
					  gs_food_image_size 
					  - self.score.view.frame.size.height / 2);
	
	self.score.view.center = scoreCenter;
	
	[self.contentView addSubview:self.score.view];
}

- (void) redraw
{
	@autoreleasepool 
	{
		[self redrawImageV];
		[self redrawScore];
	}
}


- (void) dealloc 
{
	self.foodImage = nil;
	self.score = nil;
	[super dealloc];
}

@end
