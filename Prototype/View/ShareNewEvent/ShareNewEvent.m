//
//  ShareNewEvent.m
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShareNewEvent.h"

#import "PhotoSelector.h"
#import "ImageManager.h"
#import "CreateFoodPage.h"
#import "Util.h"
#import "CreateFoodTask.h"

@interface ShareNewEvent () <PhototSelectorDelegate>
{
	PhotoSelector *_photoSelector;
	UIViewController *_delegate;
	CreateFoodPage *_createFood;
	UINavigationController *_navco;
}
@property (strong) PhotoSelector *photoSelector;
@property (strong) CreateFoodPage *createFood;
@property (strong, nonatomic) UINavigationController *navco;
@end

@implementation ShareNewEvent

@synthesize photoSelector = _photoSelector;
@synthesize delegate = _delegate;
@synthesize createFood = _createFood;
@synthesize navco = _navco;

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			if (nil == self.createFood)
			{
				self.createFood = [[[CreateFoodPage alloc] init] autorelease];
			}
			
			if (nil ==  self.navco)
			{
				self.navco = [[[UINavigationController alloc] initWithRootViewController:self.createFood] autorelease];
				CONFIG_NAGIVATION_BAR(self.navco.navigationBar);
			}
		}
	}
	
	return self;
}

- (void) dealloc
{
	self.photoSelector = nil;
	self.delegate = nil;
	self.createFood = nil;
	self.navco = nil;
	
	[super dealloc];
}

#pragma mark - PhototSelectorDelegate

- (void) showModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self.delegate presentModalViewController:vc animated:animation];
}

- (void) dismissModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self.delegate dismissModalViewControllerAnimated:animation];
}

- (void) didSelectPhotoWithSelector:(PhotoSelector *)selector
{
	@autoreleasepool 
	{
		CreateFoodTask *task = [[[CreateFoodTask alloc] init] autorelease];
		
		[task start];
		[task picSelected:selector.selectedImage];
		
		[self.delegate dismissModalViewControllerAnimated:NO];
		
		self.createFood.task = task;
		[self.createFood resetImage:selector.selectedImage];
		[self.delegate presentModalViewController:self.navco animated:NO];
	}
}

#pragma mark - interface

- (void) start
{
	@autoreleasepool 
	{
		if (nil == self.photoSelector)
		{
			self.photoSelector = [[[PhotoSelector alloc] init] autorelease];
			self.photoSelector.delegate = self;
		}

		[self.photoSelector.actionSheet showInView:self.delegate.view];
	}
}

@end
