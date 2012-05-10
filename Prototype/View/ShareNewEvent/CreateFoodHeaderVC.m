//
//  CreateFoodHeaderVC.m
//  Prototype
//
//  Created by Adrian Lee on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodHeaderVC.h"

@interface CreateFoodHeaderVC ()

@end

@implementation CreateFoodHeaderVC
@synthesize score;
@synthesize special;
@synthesize valued;
@synthesize health;
@synthesize image;
@synthesize indicator;

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil 
		bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		// Custom initialization
	}
	
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self.indicator startAnimating];
}

- (void) viewDidUnload
{
	[self setScore:nil];
	[self setSpecial:nil];
	[self setValued:nil];
	[self setHealth:nil];
	[self setImage:nil];
	
	[self setIndicator:nil];
	[super viewDidUnload];
}

- (void) dealloc 
{
	[score release];
	[special release];
	[valued release];
	[health release];
	[image release];
	
	[indicator release];
	[super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button action

- (IBAction) scoreChanged:(id)sender 
{
	if ([sender isKindOfClass:[UISlider class]]) 
	{
		float scoreValue = [(UISlider *)sender value];
		
		if (scoreValue > 9.9)
		{
			self.score.text = [NSString stringWithFormat:@"%d", (NSInteger)scoreValue];
		}
		else if (0 < ((NSInteger)(scoreValue * 10) % 10)) // if score has decimal
		{
			self.score.text = [NSString stringWithFormat:@"%.1f", scoreValue];	
		}
		else if (0 <= scoreValue)
		{
			self.score.text = [NSString stringWithFormat:@" %d ", (NSInteger)scoreValue];
		}
	}
}

- (IBAction) tapButton:(id)sender 
{
	if ([sender isKindOfClass:[UIButton class]]) 
	{
		UIButton *button = (UIButton *)sender;
		
		button.selected = !button.selected;
	}
}

#pragma mark - interface 

- (void) cleanHeader
{
	self.image.picID = nil;
	
	self.special.selected = NO;
	self.valued.selected = NO;
	self.health.selected = NO;
	
	[self.indicator startAnimating];
}

@end
