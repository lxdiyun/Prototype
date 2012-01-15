//
//  FoutCountView.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FourCountView.h"

#import "Util.h"

const static CGFloat SINGLE_LABEL_WIDTH = 25.0;

@interface FourCountView ()
{
	NSDictionary *_foodDict;
	UILabel *_tasty;
	UILabel *_special;
	UILabel *_valued;
	UILabel *_healthy;
}

@property (strong, nonatomic) NSDictionary *foodDict;
@property (strong, nonatomic) UILabel *tasty;
@property (strong, nonatomic) UILabel *special;
@property (strong, nonatomic) UILabel *valued;
@property (strong, nonatomic) UILabel *healthy;

@end

@implementation FourCountView

@synthesize foodDict = _foodDict;
@synthesize tasty = _tasty;
@synthesize special = _special;
@synthesize valued = _valued;
@synthesize healthy = _healthy;

#pragma mark - class method

+ (CGFloat) calculateWidthForFood:(NSDictionary *)foodDict
{
	uint32_t count = 0;
	
	if (0 < [[foodDict valueForKey:@"like_tasty_count"] unsignedIntValue])
	{
		++count;
	}
	
	if (0 < [[foodDict valueForKey:@"like_special_count"] unsignedIntValue])
	{
		++count;
	}
	
	if (0 < [[foodDict valueForKey:@"like_valued_count"] unsignedIntValue])
	{
		++count;
	}
	
	if (0 < [[foodDict valueForKey:@"like_healthy_count"] unsignedIntValue])
	{
		++count;
	}
	
	return count * SINGLE_LABEL_WIDTH * PROPORTION();
}

#pragma mark - life circle

- (id) initWithFrame:(CGRect)frame andFoodDict:(NSDictionary *)foodDict
{
    self = [super initWithFrame:frame];
    if (self) 
    {
	    self.foodDict = foodDict;
    }
    return self;
}

- (void) dealloc
{
	self.foodDict = nil;
	self.tasty = nil;
	self.special = nil;
	self.valued = nil;
	self.healthy = nil;
	
	[super dealloc];
}

# pragma draw view
- (void) redrawFourLabel
{
	CGFloat X = 0;
	CGFloat width = 0;
	CGFloat height = self.frame.size.height;
	uint32_t tasty = [[self.foodDict valueForKey:@"like_tasty_count"] unsignedIntValue];
	uint32_t specail = [[self.foodDict valueForKey:@"like_special_count"] unsignedIntValue]; 
	uint32_t valued = [[self.foodDict valueForKey:@"like_valued_count"] unsignedIntValue];
	uint32_t healthy = [[self.foodDict valueForKey:@"like_healthy_count"] unsignedIntValue];
	CGFloat totalValue = tasty + specail + valued + healthy;
	CGFloat totalWidth = self.frame.size.width;
	
	if (self.tasty != nil)
	{
		[self.tasty removeFromSuperview];
	}
	
	if (0 < tasty)
	{
		width = tasty * totalWidth / totalValue;
		self.tasty = [[[UILabel alloc] initWithFrame:CGRectMake(X, 
									0, 
									width, 
									height)] 
			      autorelease];
		self.tasty.backgroundColor = [Color tastyColor];
		X += width - 1 ;
		[self addSubview:self.tasty];
	}
	
	if (self.special != nil)
	{
		[self.special removeFromSuperview];
	}
	
	if (0 < specail)
	{
		width = specail * totalWidth / totalValue;
		self.special = [[[UILabel alloc] initWithFrame:CGRectMake(X, 
									  0, 
									  width, 
									  height)] 
				autorelease];
		self.special.backgroundColor = [Color specailColor];
		X += width - 1;
		[self addSubview:self.special];
	}
	
	if (self.valued != nil)
	{
		[self.valued removeFromSuperview];
	}
	
	if (0 < valued)
	{
		width = valued * totalWidth / totalValue;
		self.valued = [[[UILabel alloc] initWithFrame:CGRectMake(X, 
									 0, 
									 width, 
									 height)] 
			       autorelease];
		self.valued.backgroundColor = [Color valuedColor];
		X += width - 1;
		[self addSubview:self.valued];
	}
	
	if (self.healthy != nil)
	{
		[self.healthy removeFromSuperview];
	}
	
	if (0 < healthy)
	{
		width = healthy * totalWidth / totalValue;
		
		self.healthy = [[[UILabel alloc] initWithFrame:CGRectMake(X, 
									  0, 
									  width, 
									  height)] 
				autorelease];
		self.healthy.backgroundColor = [Color healthyColor];
		// X += width - 1;
		[self addSubview:self.healthy];
	}
}

- (void) setFoodDict:(NSDictionary *)foodDict
{
	if (_foodDict == foodDict)
	{
		return;
	}
	
	[_foodDict release];
	
	_foodDict = [foodDict retain];

	if (nil != _foodDict)
	{
		@autoreleasepool
		{
			[self redrawFourLabel];
		}
	}
}


@end
