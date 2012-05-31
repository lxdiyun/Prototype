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
#import "FoodManager.h"

@interface PlaceDetailPage () 
{
	NSInteger _foodIndex;
	NSDictionary *_placeObject;
	MapFoodPage *_leftFoodPage;
	MapFoodPage *_currentFoodPage;
	MapFoodPage *_rightFoodPage;
}

@property (assign, nonatomic) NSInteger foodIndex;
@property (strong, nonatomic) MapFoodPage *leftFoodPage;
@property (strong, nonatomic) MapFoodPage *currentFoodPage;
@property (strong, nonatomic) MapFoodPage *rightFoodPage;

@end

@implementation PlaceDetailPage
@synthesize pageControl;
@synthesize foodsView;
@synthesize foodTitle;
@synthesize delegate;
@synthesize foodIndex = _foodIndex;
@synthesize placeObject = _placeObject;
@synthesize leftFoodPage = _leftFoodPage;
@synthesize currentFoodPage = _currentFoodPage;
@synthesize rightFoodPage = _rightFoodPage;


#pragma mark - life circle

- (void) dealloc
{
	self.delegate = nil;
	self.placeObject = nil;
	
	[pageControl release];
	[foodsView release];
	[foodTitle release];
	[super dealloc];
}

#pragma mark - view life circle


- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self initGUI];
	
	[self updatePlace];
}

- (void) viewDidUnload
{
	self.delegate = nil;
	self.placeObject = nil;

	[self setPageControl:nil];
	[self setFoodsView:nil];
	[self setFoodTitle:nil];

	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - gesture hanlder

- (void) tap:(UITapGestureRecognizer *)recognizer
{
	if (self.foodTitle.alpha <= 0.1)
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

#pragma mark - object manage

- (void) updateFood
{
	NSArray *foodsIDArray = [self.placeObject valueForKey:@"foods"];
	
	if (foodsIDArray.count > self.foodIndex)
	{
		NSNumber *foodID = [foodsIDArray objectAtIndex:self.foodIndex];
		
		self.currentFoodPage.foodID = foodID;
		self.foodTitle.foodID = foodID;
		[self.pageControl setCurrentPage:self.foodIndex];
		[self showTitleAndPageControlInstanly];
	}
}

- (void) updatePlace
{
	NSArray *foodsIDArray = [self.placeObject valueForKey:@"foods"];
	[self.pageControl setNumberOfPages:[foodsIDArray count]];
	
	CGFloat contentWidth = self.foodsView.frame.size.width * foodsIDArray.count;
	
	self.foodsView.contentSize = CGSizeMake(contentWidth , self.foodsView.frame.size.height);

	[self initFoodPage];

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
	
	[self.foodTitle setAlpha:0.0];
	[self.pageControl setAlpha:0.0];
	
	[UIView commitAnimations];
}

- (void) showTitleAndPageControlInstanly
{
	
	[self.foodTitle setAlpha:1.0];
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

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
	NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

	[self updateFoodPage:page];	
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		// initilizate gui
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

		UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
		
		[self.view addGestureRecognizer:tap];
		
		if (nil == self.leftFoodPage)
		{
			self.leftFoodPage = [MapFoodPage createFromXIB];
		}
		
		if (nil == self.currentFoodPage)
		{
			self.currentFoodPage = [MapFoodPage createFromXIB];
		}
		
		if (nil == self.rightFoodPage)
		{
			self.rightFoodPage = [MapFoodPage createFromXIB];
		}
	} 
}

- (void) updateFoodWithAnnmination:(NSString *)transitionSubtype
{
	[self updateFood];
	
	CATransition* transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.subtype = transitionSubtype;
	[self.pageControl.layer addAnimation:transition forKey:@"swape-transition"];
	[self.foodTitle.layer addAnimation:transition forKey:@"swape-transition"];
}

- (void) updateFoodPage:(NSInteger)index
{
	if (self.foodIndex < index)
	{
		self.foodIndex = index;
		[self pageRight];
		[self updateFoodWithAnnmination:kCATransitionFromLeft];
	}
	else if (self.foodIndex > index)
	{
		self.foodIndex = index;
		[self pageLeft];
		[self updateFoodWithAnnmination:kCATransitionFromRight];
	}
	
	
}

- (void) initFoodPage
{
	self.foodIndex = 0;
	
	[self redraw:self.leftFoodPage at:-1];
	[self redraw:self.currentFoodPage at:0];
	[self redraw:self.rightFoodPage at:1];
	[self.foodsView scrollRectToVisible:self.currentFoodPage.frame animated:NO];
}

- (void) pageRight
{
	NSInteger index = self.foodIndex;
	
	SWAP(&_currentFoodPage, &_rightFoodPage);
	SWAP(&_rightFoodPage, &_leftFoodPage);
	
	[self redraw:self.rightFoodPage at:index + 1];
}

- (void) pageLeft
{
	NSInteger index = self.foodIndex;
	
	SWAP(&_currentFoodPage, &_leftFoodPage);
	SWAP(&_rightFoodPage, &_leftFoodPage);
	
	[self redraw:self.leftFoodPage at:index - 1];
}

- (void) redraw:(MapFoodPage *)page at:(NSInteger)index
{
	NSArray *foodsIDArray = [self.placeObject valueForKey:@"foods"];

	[page removeFromSuperview];
	
	if ((index < foodsIDArray.count) && (0 <= index))
	{
		NSNumber *foodID = [foodsIDArray objectAtIndex:index];
		CGSize size = self.foodsView.frame.size;
		CGFloat X = self.foodsView.frame.size.width * index;
		CGRect frame = CGRectMake(X, 0, size.width, size.height);

		page.foodID = foodID;
		page.frame = frame;
		
		[self.foodsView addSubview:page];
	}
}


@end
