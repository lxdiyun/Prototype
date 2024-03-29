//
//  TagCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodInfo.h"

#import "Util.h"
#import "ProfileMananger.h"
#import "FoodManager.h"


const static NSInteger MAX_TAG_QANTITY = 3;
const static CGFloat NORMAL_BUTTON_BAR_WIDTH = 80.0;
const static CGFloat BUTTON_BAR_PADDING = 20.0;
const static CGFloat USER_OWNED_BUTTON_BAR_WIDTH = 141.0;

@interface FoodInfo () 
{
	NSDictionary *_food;
	NSInteger _tagMaxIndex;
	id<FoodInfoDelegate> _delegate;
}

@end

@implementation FoodInfo

@synthesize food = _food;
@synthesize delegate = _delegate;


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
		[self addTagwithColor:[Color specail] andText:@"特色"];
	}
}

- (void) updateValued
{
	BOOL flag = [[self.food valueForKey:@"like_valued"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color valued] andText:@"超值"];
	}
}

- (void) updateHealth
{
	BOOL flag = [[self.food valueForKey:@"like_healthy"] boolValue];
	
	if (flag)
	{
		[self addTagwithColor:[Color healthy] andText:@"健康"];
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

- (void) updateTags
{
	_tagMaxIndex = 0;
	[self updateHealth];
	[self updateValued];
	[self updateSpecial];
	[self cleanNotUsedTag];
}

#pragma mark - GUI buttons

- (void) updateButtons
{
	self.target.selected = YES;
	self.ate.enabled = NO;
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

#pragma mark - view life circle

- (void) viewDidLoad
{
	ROUND_RECT(self.buttons.layer);
	self.avatar.delegate = self.delegate;
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

#pragma mark - object manage

- (void) requestUserProfile
{
	NSNumber * userID = [self.food valueForKey:@"user"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.username.text = [userProfile valueForKey:@"nick"];
			self.avatar.user = userProfile;
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
}

- (void) setDelegate:(id<FoodInfoDelegate>)delegate
{
	if ([_delegate isEqual:delegate])
	{
		return;
	}
	
	_delegate = delegate;
	
	self.avatar.delegate = delegate;
}

- (void) setFood:(NSDictionary *)food
{
	if (CHECK_EQUAL(_food ,food))
	{
		return;
	}
	
	[_food release];
	
	_food = [food retain];
	
	
	@autoreleasepool
	{
		self.date.text = [self.food valueForKey:@"created_on"];
		self.image.picID = [self.food valueForKey:@"pic"];
		
		[self requestUserProfile];
		[self updateScore];
		[self updateTags];
		[self updateButtons];
	}
	
}

#pragma mark - action

- (IBAction) showUser:(id)sender 
{
	[self.avatar tap:sender];
}


@end
