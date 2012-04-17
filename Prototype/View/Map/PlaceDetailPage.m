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
#import "FoodTitleView.h"
#import "FoodDetailController.h"
#import "FoodManager.h"

@interface PlaceDetailPage ()
{
	FoodTitleView *_titleView;
	FoodDetailController *_detailController;
	NSInteger _foodIndex;
	NSDictionary *_placeObject;
}

@property (strong) FoodTitleView *titleView;
@property (strong) FoodDetailController *detailController;
@property (assign) NSInteger foodIndex;

@end

@implementation PlaceDetailPage
@synthesize foodDetailView;
@synthesize delegate;
@synthesize titleView = _titleView;
@synthesize detailController = _detailController;
@synthesize foodIndex = _foodIndex;
@synthesize placeObject = _placeObject;

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		@autoreleasepool 
		{
			// initilizate gui
			self.titleView = [[[FoodTitleView alloc] init] autorelease];
			[self.view addSubview:self.titleView.view];
			
			self.detailController = [[[FoodDetailController alloc] init] autorelease];
			
			self.foodDetailView.delegate = self.detailController;
			self.foodDetailView.dataSource = self.detailController;
			self.detailController.view = self.foodDetailView;
			
			self.foodIndex = 0;
			
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
 		} 
	}

	return self;
}

- (void) dealloc
{
	self.titleView = nil;
	self.detailController = nil;
	self.delegate = nil;
	self.placeObject = nil;
	
	[foodDetailView release];
	
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void) viewDidUnload
{
	self.titleView = nil;
	self.detailController = nil;
	self.delegate = nil;
	self.placeObject = nil;
	
	[self setFoodDetailView:nil];
	
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - gesture hanlder

- (void) swipeDown
{
	[self.delegate placeDetailPagePullDown];
}

- (void) swipeLeft
{
	NSInteger newIndex = 0;
	
	if (0 < self.foodIndex)
	{
		newIndex = self.foodIndex - 1;
	}
	else
	{
		NSInteger maxIndex = [[self.placeObject valueForKey:@"foods"] count] - 1;

		if (0 < maxIndex)
		{
			newIndex = maxIndex;
		}
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
	
	if ([[self.placeObject valueForKey:@"foods"] count] > (self.foodIndex + 1)) 
	{
		newIndex = self.foodIndex + 1;
	}
	else 
	{
		newIndex = 0;
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
	[self.view.layer addAnimation:transition forKey:@"push-transition"];
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
			self.titleView.foodObject = foodObject;
			self.detailController.foodObject = foodObject;
		}
		else 
		{
			[FoodManager requestObjectWithNumberID:foodID andHandler:@selector(updateFood) andTarget:self];
		}
	}
}

- (void) setPlaceObject:(NSDictionary *)placeObject
{
	if (_placeObject != placeObject)
	{
		[_placeObject release];
		
		_placeObject = [placeObject retain];
		
		self.foodIndex = 0;
		[self updateFood];
	}
}

@end
