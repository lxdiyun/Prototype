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

- (void) dealloc
{
	self.photoSelector = nil;
	self.delegate = nil;
	self.createFood = nil;
	self.navco = nil;
	
	[super dealloc];
}

#pragma mark - PhototSelectorDelegate

- (void) uploadImageFinisedHandler:(NSDictionary *)result
{
	
}

- (void) dismissSelector:(PhotoSelector *)selector
{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

- (void) showModalView:(UIViewController *)modalView
{
	[self.delegate presentModalViewController:modalView animated:YES];
}

- (void) uploadImage:(PhotoSelector *)selector
{
	[ImageManager createImage:selector.selectedImage 
		      withHandler:@selector(imageUploadCompleted:)
			andTarget:self.createFood];
	
	selector.selectedImage = nil;
}

- (void) didSelectPhotoWithSelector:(PhotoSelector *)selector
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
			self.navco.navigationBar.barStyle = UIBarStyleBlack;
		}
		
		[self performSelector:@selector(uploadImage:) withObject:selector afterDelay:1.0];

		[self.createFood scrollToBegin];
		[self.delegate presentModalViewController:self.navco animated:YES];
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
