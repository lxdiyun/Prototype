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
#import "MapViewPage.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface FoodInfo () 
{
	NSDictionary *_food;
	NSInteger _tagMaxIndex;
	id<ShowVCDelegate> _delegate;
	MapViewPage *_map;
}

@property (strong, nonatomic) MapViewPage *map;

@end

@implementation FoodInfo

@synthesize food = _food;
@synthesize delegate = _delegate;
@synthesize map = _map;

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

- (void) updateLocationButton
{
	if (nil != [self.food valueForKey:@"place"])
	{
		self.location.enabled = YES;
	}
	else 
	{
		self.location.enabled = NO;
	}
}

- (void) updateButtons
{
	[self updateLocationButton];
	self.target.selected = YES;
	self.ate.enabled = NO;
}

#pragma mark - update info

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
	self.map = nil;
	
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
	ROUND_RECT(self.buttons.layer);
	self.avatar.delegate = self.delegate;
}

- (void) viewDidUnload 
{
	self.food = nil;
	self.map = nil;
	
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

#pragma mark - managet object

- (void) setDelegate:(id<ShowVCDelegate>)delegate
{
	if ([_delegate isEqual:delegate])
	{
		return;
	}
	
	_delegate = delegate;
	
	self.avatar.delegate = delegate;
}

#pragma mark - button action

- (IBAction) showInMap:(id)sender 
{
	if (nil == self.map)
	{
		MapViewPage *map = [[MapViewPage alloc] init];
		self.map = map;
		
		[map release];
	}
	
	NSMutableDictionary *tempMap = [[NSMutableDictionary alloc] init];
	NSArray *placeIDArray = [[NSArray alloc] initWithObjects:[self.food valueForKey:@"place"], nil];
	
	[tempMap setValue:[self.food valueForKey:@"name"] forKey:@"title"];
	[tempMap setValue:placeIDArray forKey:@"places"];
	
	self.map.mapObject = tempMap;

	if (0 < placeIDArray.count)
	{
		[self.delegate showVC:self.map];
	}
	
	[placeIDArray release];
	[tempMap release];
}

- (IBAction) showUser:(id)sender 
{
	[self.avatar tap:sender];
}

@end
