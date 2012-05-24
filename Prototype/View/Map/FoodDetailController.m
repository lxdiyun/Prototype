//
//  PlaceDetailPage.m
//  Prototype
//
//  Created by Adrian Lee on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodDetailController.h"

#import "Util.h"
#import "FoodImageCell.h"
#import "FoodDescCell.h"

const static CGFloat IMAGE_SIZE = 320;

@interface FoodDetailController ()
{
	NSDictionary *_foodObject;
	id<SwipeDelegate> _delegate;
}

@end

@implementation FoodDetailController

@synthesize foodObject = _foodObject;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)] autorelease];
	[left setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	
	[self.view addGestureRecognizer:left];
	
	UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)] autorelease];
	[right setDirection:(UISwipeGestureRecognizerDirectionRight)];
	
	[self.view addGestureRecognizer:right];
	
}

- (void)viewDidUnload
{
	self.foodObject = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	switch (indexPath.row) 
	{
		case 0:
		{
			static NSString *imageCellIdentifier = @"FoodImageCell";
			
			FoodImageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
			if (cell == nil) 
			{
				cell = [[[FoodImageCell alloc] 
					 initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:imageCellIdentifier] 
					autorelease];
				cell.frame = CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE);				
				
				UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)] autorelease];
				[left setDirection:(UISwipeGestureRecognizerDirectionLeft)];
				
				[cell addGestureRecognizer:left];
				
				UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)] autorelease];
				[right setDirection:(UISwipeGestureRecognizerDirectionRight)];
				
				[cell addGestureRecognizer:right];
				
				[cell redraw];
			}
			
			cell.foodImage.picID = [self.foodObject valueForKey:@"pic"];
			
			return cell;
		}
			break;
		case 1:
		{
			static NSString *descCellIdentifier = @"FoodMAPDescCell";
			
			FoodDescCell *cell = [tableView dequeueReusableCellWithIdentifier:descCellIdentifier];
			
			if (cell == nil) 
			{
				cell = [[[FoodDescCell alloc] 
					 initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:descCellIdentifier] 
					autorelease];
				UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)] autorelease];
				[left setDirection:(UISwipeGestureRecognizerDirectionLeft)];
				
				[cell addGestureRecognizer:left];
				
				UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)] autorelease];
				[right setDirection:(UISwipeGestureRecognizerDirectionRight)];
				
				[cell addGestureRecognizer:right];
			}
			
			cell.description = [self.foodObject valueForKey:@"desc"];
			
			return cell;
		}
			break;
		default:
		{
			
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
							       reuseIdentifier:CellIdentifier]
					autorelease];
			}
			
			return cell;
		}
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) 
	{
		case 0:
			return IMAGE_SIZE;
			break;
		case 1:
			return [FoodDescCell cellHeightForDesc:[self.foodObject valueForKey:@"desc"]];
		default:
			return DEFAULT_CELL_HEIGHT;
			break;
	}
}

#pragma mark - Table view delegate

#pragma mark - update food
- (void) setFoodObject:(NSDictionary *)foodObject
{
	if (_foodObject != foodObject)
	{
		[_foodObject release];
		
		_foodObject = [foodObject retain];
		
		[self.tableView reloadData];
	}
}

#pragma mark - gesture

- (void) swipeLeft
{
	[self.delegate swipeLeft:self];
}

- (void) swipeRight
{
	[self.delegate swipeRight:self];
}

@end
