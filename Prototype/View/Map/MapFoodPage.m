//
//  MapFoodPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFoodPage.h"

#import "FoodManager.h"

const static NSInteger MAX_TAG_QANTITY = 3;

@interface MapFoodPage ()
{
	NSNumber *_foodID;
	NSDictionary *_foodObject;
	NSInteger _tagMaxIndex;
}

@property (strong, nonatomic) NSDictionary *foodObject;

@end

@implementation MapFoodPage

@synthesize foodObject = _foodObject;
@synthesize foodID = _foodID;

@synthesize image;
@synthesize desc;

#pragma mark - custrom xib object

// two is for two scoller
DEFINE_CUSTOM_XIB(MapFoodPage, 2);

- (void) resetupXIB:(MapFoodPage *)xibInstance
{
	[xibInstance initGUI];
	
	xibInstance.frame = self.frame;
}

#pragma mark - life circle

- (void) dealloc
{
	self.foodID = nil;
	self.foodObject = nil;
	
	[image release];
	[desc release];
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
	static CGRect TopRect = {0, 0, 1, 1};
	
	NSDictionary *foodObject = [FoodManager getObjectWithNumberID:self.foodID];

	if (nil != foodObject)
	{
		self.foodObject = foodObject;
		self.image.picID = [self.foodObject valueForKey:@"pic"];
		[self updateDesc];
		CGRect content = CGRectUnion(self.desc.frame, self.image.frame);
		self.contentSize = content.size;
		[self scrollRectToVisible:TopRect animated:NO];
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
	self.image.indicatorStyle = UIActivityIndicatorViewStyleWhite;
}

- (void) updateDesc
{
	CGSize constrained = CGSizeMake(self.frame.size.width, 9999.0);
	CGSize sizeToFit;
	CGRect frame = self.desc.frame;
	
	self.desc.text = [self.foodObject valueForKey:@"desc"];
	sizeToFit = [self.desc.text sizeWithFont:self.desc.font 
			       constrainedToSize:constrained
		     lineBreakMode:self.desc.lineBreakMode];
	frame = CGRectMake(frame.origin.x, frame.origin.y, sizeToFit.width, sizeToFit.height);
	self.desc.frame = frame;
}

@end
