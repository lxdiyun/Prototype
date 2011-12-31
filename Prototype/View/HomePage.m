//
//  HomePage.m
//  Prototype
//
//  Created by Adrian Lee on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HomePage.h"

#import "Util.h"
#import "EventPage.h"
#import "UserInfoPage.h"

const static uint32_t MSWJ_PAGE_QUANTITY = 2;
static NSString *MSWJ_PAGE_NAME[MSWJ_PAGE_QUANTITY] = {@"新鲜事", @"个人设置"};
static Class MSWJ_PAGE_CLASS[MSWJ_PAGE_QUANTITY]; 
static UIViewController *MSWJ_PAGE_INSTANCE[MSWJ_PAGE_QUANTITY] = {nil};



@implementation HomePage

- (void) setupPageClass
{
	MSWJ_PAGE_CLASS[0] = [EventPage class];
	MSWJ_PAGE_CLASS[1] = [UserInfoPage class];
}

- (void) releasePageInstance
{
	for (int i = 0; i < MSWJ_PAGE_QUANTITY; ++i)
	{
		[MSWJ_PAGE_INSTANCE[i] release];
		MSWJ_PAGE_CLASS[i] = nil;
	}
}

- (void)dealloc
{
	[self releasePageInstance];
	
	[super dealloc];
}

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (nil != self) 
	{
		[self setupPageClass];
	}

	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return MSWJ_PAGE_QUANTITY;
}

- (UITableViewCell *) tableView:(UITableView *)tableView 
	  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
					       reuseIdentifier:CellIdentifier] 
			autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// Configure the cell...
	
	cell.textLabel.text = MSWJ_PAGE_NAME[indexPath.row];
	
	return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	uint32_t row = indexPath.row;
	
	if (nil == MSWJ_PAGE_INSTANCE[row])
	{
		MSWJ_PAGE_INSTANCE[row] = [[MSWJ_PAGE_CLASS[row] alloc] init];
	}
	
	[self.navigationController pushViewController:MSWJ_PAGE_INSTANCE[row] animated:YES];
}

@end
