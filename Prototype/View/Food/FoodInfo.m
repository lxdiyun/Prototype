//
//  TagCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodInfo.h"

#import <QuartzCore/QuartzCore.h>

#import "Util.h"
#import "ProfileMananger.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface FoodInfo ()
{
	NSDictionary *_food;
	NSInteger _tagMaxIndex;
}

@end

@implementation FoodInfo

@synthesize food = _food;

@synthesize buttons;
@synthesize username;
@synthesize avatar;
@synthesize date;
@synthesize target;
@synthesize ate;
@synthesize location;
@synthesize image;
@synthesize tag1Text;
@synthesize tag1;
@synthesize tag2Text;
@synthesize tag2;
@synthesize tag3Text;
@synthesize tag3;
@synthesize score;

#pragma mark - GUI tags

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
	BOOL flag = [[self.food valueForKey:@"like_special"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color specailColor] andText:@"特色"];
	}
}

- (void) updateValued
{
	BOOL flag = [[self.food valueForKey:@"like_valued"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color valuedColor] andText:@"超值"];
	}
}

- (void) updateHealth
{
	BOOL flag = [[self.food valueForKey:@"like_healthy"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color healthyColor] andText:@"健康"];
	}
}

- (void) updateScore
{
	double scoreValue = [[self.food valueForKey:@"taste_score"] doubleValue];
	
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

#pragma mark - update info

- (void) setFood:(NSDictionary *)food
{
	if (_food == food)
	{
		return;
	}
	
	[_food release];
	
	_food = [food retain];
	
	if (nil != _food)
	{
		@autoreleasepool
		{
			self.date.text = [self.food valueForKey:@"created_on"];
			self.image.picID = [self.food valueForKey:@"pic"];
			
			[self requestUserProfile];
			[self updateScore];
			_tagMaxIndex = 0;
			[self updateHealth];
			[self updateValued];
			[self updateSpecial];
			[self cleanNotUsedTag];
		}
	}
}

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (nil != self) 
	{
		_tagMaxIndex = 0;
	}
	return self;
}

- (void) dealloc
{
	self.food = nil;
	
	[buttons release];
	[date release];
	[avatar release];
	[target release];
	[ate release];
	[location release];
	[username release];
	[image release];
	[tag1Text release];
	[tag1 release];
	[tag2Text release];
	[tag2 release];
	[tag3Text release];
	[tag3 release];
	[score release];
	[super dealloc];
}

- (void) viewDidLoad
{
	self.buttons.layer.cornerRadius = 5.0;
}

- (void) viewDidUnload 
{
	self.food = nil;
	
	[self setButtons:nil];
	[self setDate:nil];
	[self setAvatar:nil];
	[self setTarget:nil];
	[self setAte:nil];
	[self setLocation:nil];
	[self setUsername:nil];
	[self setImage:nil];
	[self setTag1Text:nil];
	[self setTag1:nil];
	[self setTag2Text:nil];
	[self setTag2:nil];
	[self setTag3Text:nil];
	[self setTag3:nil];
	[self setScore:nil];
	[super viewDidUnload];
}

#pragma mark - message

- (void) requestUserProfile
{
	NSNumber * userID = [self.food valueForKey:@"user"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.username.text = [userProfile valueForKey:@"nick"];
			self.avatar.picID = [userProfile valueForKey:@"avatar"];
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
}

@end
