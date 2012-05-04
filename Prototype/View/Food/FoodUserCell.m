//
//  TagCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodUserCell.h"

#import <QuartzCore/QuartzCore.h>

#import "Util.h"
#import "ProfileMananger.h"

@interface FoodUserCell ()
{
	NSDictionary *_food;
}

@end

@implementation FoodUserCell

@synthesize food = _food;

@synthesize buttons;
@synthesize username;
@synthesize avatar;
@synthesize date;
@synthesize target;
@synthesize ate;
@synthesize location;

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
			[self requestUserProfile];
			
			self.date.text = [self.food valueForKey:@"created_on"];
		}
	}
}

#pragma mark life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
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
