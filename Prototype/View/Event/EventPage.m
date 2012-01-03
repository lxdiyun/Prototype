//
//  Event.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventPage.h"

#import "EGORefreshTableHeaderView.h"

#import "Util.h"
#import "FoodPage.h"
#import "EventCell.h"
#import "EventMessage.h"

const static uint32_t EVENT_REFRESH_WINDOW = 5;
const static uint32_t ROW_TO_MORE_EVENT_FROM_BOTTOM = 1;

@interface EventPage () <EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{	
	FoodPage *_foodPage;
	EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (strong) FoodPage *foodPage;
@property (strong) EGORefreshTableHeaderView *refreshHeaderView;

// event message
- (void) requestOlderEvent;
- (void) requestNewerEvent;

// util
- (void) refreshTableView;
@end

@implementation EventPage

@synthesize foodPage = _foodPage;
@synthesize refreshHeaderView = _refreshHeaderView;

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
	{
		// Custom initialization
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
	
	[self setTitle:@"新鲜事"];
	
	// init data
	if (nil == self.refreshHeaderView) 
	{
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
						   initWithFrame:CGRectMake(0.0f, 
									    0.0f - self.tableView.bounds.size.height, 
									    self.view.frame.size.width,
									    self.tableView.bounds.size.height)];
		
		view.delegate = self;
		[self.tableView addSubview:view];
		self.refreshHeaderView = view;
		[view release];
	}
	
	//  update the last update date
	[self.refreshHeaderView refreshLastUpdatedDate];

	// triger message
	[self requestNewerEvent];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	
	// release data 
	self.foodPage = nil;
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
	// Return the number of sections.
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return [EventMessage eventArray].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width/2);
		[cell redraw];
	}
	
	// Configure the cell...
	NSDictionary *event = [[EventMessage eventArray] objectAtIndex:indexPath.row];
	cell.eventDict = event;
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return self.view.frame.size.width/2;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *event = [[EventMessage eventArray] objectAtIndex:indexPath.row];
	
	if (nil == self.foodPage)
	{
		FoodPage *foodPage = [[FoodPage alloc] init];
		self.foodPage = foodPage;
		
		[foodPage release];
	}
	
	self.foodPage.foodDict = event;
	
	[self.navigationController pushViewController:self.foodPage animated:YES];
}

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (([EventMessage eventArray].count - ROW_TO_MORE_EVENT_FROM_BOTTOM) <= indexPath.row)
	{
		[self requestOlderEvent];
	}
}

#pragma mark - message

- (void) requestNewerEventHandler
{	
	[self refreshTableView];
	
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void) requestNewerEvent
{	
	[EventMessage requestNewerCount:EVENT_REFRESH_WINDOW withHandler:@selector(requestNewerEventHandler) andTarget:self];
}

- (void) requestOlderEvent
{
	[EventMessage requestOlderCount:EVENT_REFRESH_WINDOW withHandler:@selector(refreshTableView) andTarget:self];
}

#pragma mark - util
- (void) refreshTableView
{
	static uint32_t s_lassEventArrayCount = 0;
	uint32_t eventArrayCount = [[EventMessage eventArray] count];
	
	if (s_lassEventArrayCount < eventArrayCount) 
	{
		if ([self.view respondsToSelector:@selector(reloadData)])
		{
			[self.view performSelector:@selector(reloadData)];
		}
		s_lassEventArrayCount = eventArrayCount;
	}
}

#pragma mark - UIScrollViewDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self requestNewerEvent];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [EventMessage isNewerUpdating]; 
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	NSDate *updatedDate = [EventMessage lastUpdatedDate];
	
	if (nil != updatedDate)
	{
		return updatedDate;
	}
	else
	{
		return [NSDate date];
	}
}


@end
