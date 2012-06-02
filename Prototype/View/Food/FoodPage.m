//
//  FoodPage.m
//  Prototype
//
//  Created by Adrian Lee on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodPage.h"

#import "Util.h"
#import "DetailFoodVC.h"

@interface FoodPage () <FoodToolBarDelegate>
{
	DetailFoodVC *_detailFoodVC;
	NSNumber *_foodID;
}

@property (strong, nonatomic) DetailFoodVC *detailFoodVC;

@end

@implementation FoodPage

@synthesize detailFoodVC = _detailFoodVC;
@synthesize foodID = _foodID;

@synthesize toolbar;


#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		DetailFoodVC *detailFoodVC = [[DetailFoodVC alloc] init];
		
		detailFoodVC.delegate = self;
		self.detailFoodVC = detailFoodVC;
		
		[detailFoodVC release];
		
		self.hidesBottomBarWhenPushed = YES;
	}

	return self;
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	HANDLE_MEMORY_WARNING(self);
}

- (void) dealloc 
{
	self.foodID = nil;

	[toolbar release];
	
	[super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - view life circle

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	self.navigationController.tabBarController.tabBar.hidden = YES;
	
	[self.detailFoodVC viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[self.detailFoodVC viewDidDisappear:animated];
	
//	self.navigationController.tabBarController.tabBar.hidden = NO;
}


- (void) viewDidLoad
{
	[super viewDidLoad];

	[self.detailFoodVC viewDidLoad];
	
	[self initGUI];
}

- (void) viewDidUnload
{
	[self setToolbar:nil];
	
	[self.detailFoodVC viewDidUnload];

	[super viewDidUnload];
}

#pragma mark - object manage

- (void) setFoodID:(NSNumber *)foodID
{
	if (CHECK_EQUAL(self.detailFoodVC.foodID, foodID))
	{
		return;
	}
	
	_foodID = foodID;

	self.detailFoodVC.foodID = foodID;
	self.detailFoodVC.tableView.contentOffset = CGPointZero;
}

#pragma mark - FoodToolBarDelegate

- (void) foodDeleted:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) comentCreated:(id)result
{
	[self.detailFoodVC requestNewestComment];
	[self.detailFoodVC reloadCommentSection];
}

- (void) showModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self dismissModalViewControllerAnimated:NO];
	[self presentModalViewController:vc animated:animation];
}

- (void) dismissModalVC:(UIViewController *)vc withAnimation:(BOOL)animation
{
	[self dismissModalViewControllerAnimated:animation];
}

#pragma mark - DetailFoodPageDelegate

- (void) showVC:(UIViewController *)VC
{
	self.hidesBottomBarWhenPushed = NO;
	[self.navigationController pushViewController:VC animated:YES];
//	self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - GUI

- (void) initGUI
{
	self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, 
								      @selector(backToPrevView));
	CGRect frame = self.view.frame;
	frame.size.height -= self.toolbar.frame.size.height;
	self.detailFoodVC.view.frame = frame;
	
	[self.view addSubview:self.detailFoodVC.view];
	
	self.toolbar.delegate = self;
	[self.view bringSubviewToFront:self.toolbar];
	
}

- (void) backToPrevView
{
//	self.hidesBottomBarWhenPushed = NO;
	[self.navigationController popViewControllerAnimated:YES];
//	self.hidesBottomBarWhenPushed = YES;
}

@end
