//
//  FoodScore.m
//  Prototype
//
//  Created by Adrian Lee on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodScore.h"
#import "Util.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface FoodScore ()
{
	NSDictionary *_foodObject;
	NSInteger _tagMaxIndex;
}

@end

@implementation FoodScore
@synthesize score;
@synthesize tag3;
@synthesize tag3Text;
@synthesize tag2;
@synthesize tag2Text;
@synthesize tag1;
@synthesize tag1Text;
@synthesize foodObject = _foodObject;

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		_tagMaxIndex = 0;
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[self setScore:nil];
	self.foodObject = nil;

	[self setTag3:nil];
	[self setTag3Text:nil];
	[self setTag2:nil];
	[self setTag2Text:nil];
	[self setTag1:nil];
	[self setTag1Text:nil];

	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	[score release];
	[tag3 release];
	[tag3Text release];
	[tag2 release];
	[tag2Text release];
	[tag1 release];
	[tag1Text release];
	self.foodObject = nil;

	[super dealloc];
}

#pragma mark - tags

- (void) setTag:(NSInteger)tagIndex withColor:(UIColor *)color andText:(NSString *)text
{
	switch (tagIndex) 
	{
		case 0:
		{
			self.tag1.backgroundColor = color;
			self.tag1Text.text = text;
		}
			break;
		case 1:
		{
			self.tag2.backgroundColor = color;
			self.tag2Text.text = text;
		}
			break;
		case 2:
		{
			self.tag3.backgroundColor = color;
			self.tag3Text.text = text;
		}
			break;
			
		default:
			break;
	}
}

- (void) cleanNotUsedTag
{
	for (int i = _tagMaxIndex; i < MAX_TAG_QANTITY; ++i) 
	{
		[self setTag:i withColor:[UIColor clearColor] andText:@""];
	}
	
	_tagMaxIndex = 0;
}

- (void) addTagwithColor:(UIColor *)color andText:(NSString *)text
{
	[self setTag:_tagMaxIndex withColor:color andText:text];
	++_tagMaxIndex;
}

#pragma mark - tags

- (void) updateSpecial
{
	BOOL flag = [[self.foodObject valueForKey:@"like_special"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color specailColor] andText:@"特色"];
	}
}

- (void) updateValued
{
	BOOL flag = [[self.foodObject valueForKey:@"like_valued"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color valuedColor] andText:@"超值"];
	}
}

- (void) updateHealth
{
	BOOL flag = [[self.foodObject valueForKey:@"like_healthy"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color healthyColor] andText:@"健康"];
	}
}

- (void) updateScore
{
	double scoreValue = [[self.foodObject valueForKey:@"taste_score"] doubleValue];
	
	if (scoreValue >= 10.0)
	{
		self.score.text = [NSString stringWithFormat:@"%d", (NSInteger)scoreValue];
	}
	else if (0 < ((NSInteger)(scoreValue * 10) % 10)) // if score has decimal
	{
		self.score.text = [NSString stringWithFormat:@"%.1f", scoreValue];	
	}
	else if (0 < scoreValue)
	{
		self.score.text = [NSString stringWithFormat:@" %d ", (NSInteger)scoreValue];
	}
	else 
	{
		self.score.text =@"－";
	}
	
}

- (void) updateFoodTitle
{
	@autoreleasepool 
	{
		[self updateScore];
		_tagMaxIndex = 0;
		[self updateHealth];
		[self updateValued];
		[self updateSpecial];
		[self cleanNotUsedTag];
	}
}

- (void) setFoodObject:(NSDictionary *)foodObject
{
	if (_foodObject != foodObject)
	{
		[_foodObject release];
		_foodObject = [foodObject retain];
		
		[self updateFoodTitle];
	}
}

@end
