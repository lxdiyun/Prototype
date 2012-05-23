//
//  PlaceDetailPage.m
//  Prototype
//
//  Created by Adrian Lee on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceDetailPage.h"

#import <QuartzCore/QuartzCore.h>

#import "Util.h"
#import "FoodDetailController.h"
#import "FoodManager.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface PlaceDetailPage ()
{
	FoodDetailController *_detailController;
	NSDictionary *_foodObject;
	NSInteger _foodIndex;
	NSDictionary *_placeObject;
	NSInteger _tagMaxIndex;
}

@property (strong) FoodDetailController *detailController;
@property (assign) NSInteger foodIndex;
@property (strong) NSDictionary *foodObject;

@end

@implementation PlaceDetailPage
@synthesize foodDetailView;
@synthesize pageControl;
@synthesize name;
@synthesize score;
@synthesize tag3;
@synthesize tag3Text;
@synthesize tag2;
@synthesize tag2Text;
@synthesize tag1;
@synthesize tag1Text;
@synthesize titleView;
@synthesize delegate;
@synthesize detailController = _detailController;
@synthesize foodIndex = _foodIndex;
@synthesize placeObject = _placeObject;
@synthesize foodObject = _foodObject;


#pragma mark - life circle

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
	self.titleView = nil;
	self.detailController = nil;
	self.delegate = nil;
	self.placeObject = nil;
	self.foodObject = nil;
	[name release];
	[score release];
	[tag3 release];
	[tag3Text release];
	[tag2 release];
	[tag2Text release];
	[tag1 release];
	[tag1Text release];
	
	[foodDetailView release];
	
	[pageControl release];
	[titleView release];
	[super dealloc];
}

- (void) setupView
{
	@autoreleasepool 
	{
		// initilizate gui
		_tagMaxIndex = 0;
		
		self.detailController = [[[FoodDetailController alloc] init] autorelease];
		
		self.foodDetailView.delegate = self.detailController;
		self.foodDetailView.dataSource = self.detailController;
		self.detailController.view = self.foodDetailView;
		self.pageControl.frame = CGRectMake(0, self.view.frame.size.height - 18, self.view.frame.size.width, 18);
		
		
		// shadow
		[self.view.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.view.layer setShadowOpacity:0.5];
		[self.view.layer setShadowRadius:10];
		[self.view.layer setShadowOffset:CGSizeMake(0.0, -6.0)];
		
		// handle gesture
		UISwipeGestureRecognizer *down = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown)] autorelease];
		[down setDirection:(UISwipeGestureRecognizerDirectionDown)];
		
		[self.view addGestureRecognizer:down];
		
		UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)] autorelease];
		[left setDirection:(UISwipeGestureRecognizerDirectionLeft)];
		
		[self.view addGestureRecognizer:left];
		
		UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)] autorelease];
		[right setDirection:(UISwipeGestureRecognizerDirectionRight)];
		
		[self.view addGestureRecognizer:right];
		
		UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
		
		[self.view addGestureRecognizer:tap];
	} 
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self setupView];
	
	[self updatePlace];
}

- (void) viewDidUnload
{
	self.titleView = nil;
	self.detailController = nil;
	self.delegate = nil;
	self.placeObject = nil;
	self.foodObject = nil;
	
	[self setFoodDetailView:nil];
	[self setName:nil];
	[self setScore:nil];
	[self setTag3:nil];
	[self setTag3Text:nil];
	[self setTag2:nil];
	[self setTag2Text:nil];
	[self setTag1:nil];
	[self setTag1Text:nil];	
	[self setPageControl:nil];

	[self setTitleView:nil];
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - gesture hanlder

- (void) tap:(UITapGestureRecognizer *)recognizer
{
	if (self.titleView.alpha <= 0.1)
	{
		[self showTitleAndPageControl];
	}
	else 
	{
		[self hideTitleAndPageControl];
	}
}

- (void) swipeDown
{
	[self.delegate placeDetailPagePullDown];
}

- (void) swipeLeft
{
	NSInteger newIndex = self.foodIndex;
	
	if ([[self.placeObject valueForKey:@"foods"] count] > (self.foodIndex + 1)) 
	{
		newIndex = self.foodIndex + 1;
	}
	
	if (self.foodIndex != newIndex)
	{
		self.foodIndex = newIndex;
		[self updaeFoodWithAnnmination:kCATransitionFromRight];
	}
}

- (void) swipeRight
{
	NSInteger newIndex = 0;
	
	if (0 < self.foodIndex)
	{
		newIndex = self.foodIndex - 1;
	}
	
	if (self.foodIndex != newIndex)
	{
		self.foodIndex = newIndex;
		[self updaeFoodWithAnnmination:kCATransitionFromLeft];
	}
}

#pragma mark - update detail page

- (void) updaeFoodWithAnnmination:(NSString *)transitionSubtype
{
	[self updateFood];
	
	CATransition* transition = [CATransition animation];
	transition.type = kCATransitionPush;
	transition.subtype = transitionSubtype;
	[self.titleView.layer addAnimation:transition forKey:@"push-transition"];
	[self.foodDetailView.layer addAnimation:transition forKey:@"push-transition"];
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

- (void) updateFood
{
	NSArray *foodsIDArray = [self.placeObject valueForKey:@"foods"];
	
	if (foodsIDArray.count > self.foodIndex)
	{
		NSNumber *foodID = [foodsIDArray objectAtIndex:self.foodIndex];
		
		NSDictionary *foodObject = [FoodManager getObjectWithNumberID:foodID];
		
		if (nil != foodObject)
		{
			self.foodObject = foodObject;
			[self updateFoodTitle];
			self.detailController.foodObject = foodObject;
			[self.pageControl setCurrentPage:self.foodIndex];
			[self showTitleAndPageControlInstanly];
		}
		else 
		{
			[FoodManager requestObjectWithNumberID:foodID 
						    andHandler:@selector(updateFood) 
						     andTarget:self];
		}
	}
}

- (void) updatePlace
{
	NSArray *foodsIDArray = [self.placeObject valueForKey:@"foods"];
	[self.pageControl setNumberOfPages:[foodsIDArray count]];

	self.foodIndex = 0;
	[self updateFood];
}

- (void) setPlaceObject:(NSDictionary *)placeObject
{
	if (_placeObject != placeObject)
	{
		[_placeObject release];
		
		_placeObject = [placeObject retain];
		
		[self updatePlace];
	}
}

#pragma mark - hide or show title and pageControl

- (void) hideTitleAndPageControl
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	
	[self.titleView setAlpha:0.0];
	[self.pageControl setAlpha:0.0];
	
	[UIView commitAnimations];
}

- (void) showTitleAndPageControlInstanly
{
	
	[self.titleView setAlpha:1.0];
	[self.pageControl setAlpha:1.0];
}

- (void) showTitleAndPageControl
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	
	[self showTitleAndPageControlInstanly];
	
	[UIView commitAnimations];
}

@end
