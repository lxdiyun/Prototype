//
//  MapFoodHeader.m
//  Prototype
//
//  Created by Adrian Lee on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFoodHeader.h"

#import "FoodManager.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface MapFoodHeader ()
{
	NSNumber *_foodID;
	NSDictionary *_foodObject;
	NSInteger _tagMaxIndex;
}

@property (strong, nonatomic) NSDictionary *foodObject;

@end

@implementation MapFoodHeader

@synthesize foodObject = _foodObject;
@synthesize foodID = _foodID;

@synthesize name;
@synthesize score;
@synthesize tag3;
@synthesize tag3Text;
@synthesize tag2;
@synthesize tag2Text;
@synthesize tag1;
@synthesize tag1Text;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(MapFoodHeader, 0);

- (void) resetupXIB:(MapFoodHeader *)xibInstance
{
	[xibInstance initGUI];
	
	xibInstance.frame = self.frame;
	xibInstance.userInteractionEnabled = self.userInteractionEnabled;
}

#pragma mark - life circle

- (void) dealloc
{
	self.foodID = nil;
	self.foodObject = nil;
	
	[name release];
	[score release];
	[tag3 release];
	[tag3Text release];
	[tag2 release];
	[tag2Text release];
	[tag1 release];
	[tag1Text release];
	
	[super dealloc];	
}

#pragma mark - object manage

- (void) setFoodID:(NSNumber *)foodID
{
	if (CHECK_EQUAL(_foodID, foodID))
	{
		return;
	}
	
	[_foodID release];
	_foodID = [foodID retain];
	
	[self updateFood];
}

- (void) updateFood
{
	
	NSDictionary *foodObject = [FoodManager getObjectWithNumberID:self.foodID];
	
	if (nil != foodObject)
	{
		self.foodObject = foodObject;
		[self updateFoodTitle];
	}
	else 
	{
		[FoodManager requestObjectWithNumberID:self.foodID
					    andHandler:@selector(updateFood) 
					     andTarget:self];
	}
	
}

#pragma mark - GUI

- (void) initGUI
{
	
}

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

- (void) updateSpecial
{
	BOOL flag = [[self.foodObject valueForKey:@"like_special"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color specail] andText:@"特色"];
	}
}

- (void) updateValued
{
	BOOL flag = [[self.foodObject valueForKey:@"like_valued"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color valued] andText:@"超值"];
	}
}

- (void) updateHealth
{
	BOOL flag = [[self.foodObject valueForKey:@"like_healthy"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color healthy] andText:@"健康"];
	}
}

- (void) updateScore
{
	double scoreValue = [[self.foodObject valueForKey:@"taste_score"] doubleValue];
	
	self.score.text = GET_STRING_FOR_SCORE(scoreValue);	
}

- (void) updateName
{
	NSString *foodName = [self.foodObject valueForKey:@"name"];
	
	if (nil != name)
	{
		self.name.text = foodName;
	}
	else 
	{
		self.name.text = @"";
	}
}

- (void) updateFoodTitle
{
	@autoreleasepool 
	{
		[self updateName];
		[self updateScore];
		_tagMaxIndex = 0;
		[self updateHealth];
		[self updateValued];
		[self updateSpecial];
		[self cleanNotUsedTag];
	}
}

@end
