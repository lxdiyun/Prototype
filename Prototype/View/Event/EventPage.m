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
#import "EventManager.h"

const static uint32_t EVENT_REFRESH_WINDOW = 10;
const static uint32_t ROW_TO_MORE_EVENT_FROM_BOTTOM = 1;

@interface EventPage () <EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{	
	UIScrollView *_scrollColumn;
	UITableView *_leftColumn;
	UITableView *_rightColumn;
	FoodPage *_foodPage;
	EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (strong) UIScrollView *scrollColumn;
@property (strong) UITableView *leftColumn;
@property (strong) UITableView *rightColumn;
@property (strong) FoodPage *foodPage;
@property (strong) EGORefreshTableHeaderView *refreshHeaderView;

// event message
- (void) requestOlderEvent;
- (void) requestNewerEvent;

// util
- (void) refreshTableView;
@end

@implementation EventPage

@synthesize scrollColumn = _scrollColumn;
@synthesize leftColumn = _leftColumn;
@synthesize rightColumn = _rightColumn;
@synthesize foodPage = _foodPage;
@synthesize refreshHeaderView = _refreshHeaderView;

static CGFloat gs_frame_width;
static CGFloat gs_frame_height;

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) setupView
{
	gs_frame_width = self.view.frame.size.width;
	gs_frame_height = self.view.frame.size.height;
	
	self.view.backgroundColor = [Color brownColor];
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.leftColumn indexPathForSelectedRow];
	[self.leftColumn deselectRowAtIndexPath:tableSelection animated:YES];
	tableSelection = [self.rightColumn indexPathForSelectedRow];
	[self.rightColumn deselectRowAtIndexPath:tableSelection animated:YES];
	
	// init scroll column
	if (nil == self.scrollColumn)
	{
		UIScrollView *view = [[UIScrollView alloc] 
				     initWithFrame:CGRectMake(0, 
							      0, 
							      gs_frame_width, 
							      gs_frame_height)];
		view.delegate = self;
		view.showsVerticalScrollIndicator = YES;
		view.backgroundColor = [UIColor clearColor];
		view.bounces = NO;
		view.scrollsToTop = NO;
		
		[self.view addSubview:view];
		self.scrollColumn = view;
		
		[view release];
	}

	// init left column
	if(nil == self.leftColumn)
	{
		UITableView *view = [[UITableView alloc] 
			initWithFrame:CGRectMake(0, 
						 0, 
						 gs_frame_width, 
						 gs_frame_height) 
			style:UITableViewStylePlain];
		view.delegate = self;
		view.dataSource = self;
		view.backgroundColor = [UIColor clearColor];
		view.showsVerticalScrollIndicator = NO;
		view.separatorStyle = UITableViewCellSeparatorStyleNone;
		view.alwaysBounceVertical = NO;
		view.bounces = NO;
		view.scrollsToTop = NO;

		[self.scrollColumn addSubview:view];
		self.leftColumn = view;
		
		[view release];
	}

	// init right Column
	if(nil == self.rightColumn)
	{
		UITableView *view = [[UITableView alloc] 
			initWithFrame:CGRectMake(gs_frame_width/2,
						 0,
						 gs_frame_width/2, 
						 gs_frame_height) 
			style:UITableViewStylePlain];
		view.delegate = self;
		view.dataSource = self;
		view.backgroundColor = [UIColor clearColor];
		view.separatorStyle = UITableViewCellSeparatorStyleNone;
		view.alwaysBounceVertical = NO;
		view.bounces = NO;
		view.scrollsToTop = YES;
		
		[self.scrollColumn addSubview:view];
		self.rightColumn = view;
		
		[view release];
	}
	
	// init header
	if (nil == self.refreshHeaderView) 
	{
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
						   initWithFrame:CGRectMake(0.0f, 
									    0.0f - self.leftColumn.bounds.size.height, 
									    gs_frame_width,
									    self.leftColumn.bounds.size.height)];
		
		view.delegate = self;
		[self.leftColumn addSubview:view];
		
		self.refreshHeaderView = view;
		[view release];
	}
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	[self setTitle:@"新鲜事"];
	
	UIView *view = [[UIView alloc] init];
	self.view = view;
	[view release];

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
	self.scrollColumn = nil;
	self.leftColumn = nil;
	self.rightColumn = nil;
	self.foodPage = nil;
	self.refreshHeaderView = nil;
}

- (void) viewWillAppear:(BOOL)animated
{	
	[self setupView];
	
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

- (NSInteger) getEventIndexTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	int32_t eventIndex = -1;
	if (self.leftColumn == tableView)
	{
		eventIndex = 2 * indexPath.row;
	}
	else
	{
		eventIndex = 2 * (indexPath.row - 1) + 1;
	}
	
	return eventIndex;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	uint32_t count = [EventManager eventKeyArray].count;
	return count/2 + 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, gs_frame_width/2, gs_frame_width/2);
		[cell redraw];
	}

	// Configure the cell...
	int32_t eventIndex = [self getEventIndexTableView:tableView indexPath:indexPath];
	
	if (eventIndex < [[EventManager eventKeyArray] count] && 0 <= eventIndex) 
	{
		NSString *eventID = [[EventManager eventKeyArray] objectAtIndex:eventIndex];
		NSDictionary *event = [EventManager getObjectWithStringID:eventID];
		cell.eventDict = event;
	}	
	else
	{
		cell.eventDict = nil;
	}

	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return gs_frame_width/2;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	int32_t eventIndex = [self getEventIndexTableView:tableView indexPath:indexPath];
	
	if (eventIndex < [[EventManager eventKeyArray] count] && 0 <= eventIndex)
	{
		
		return indexPath;
	}
	else
	{
		return nil;
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (nil == self.foodPage)
	{
		FoodPage *foodPage = [[FoodPage alloc] init];
		self.foodPage = foodPage;
		
		[foodPage release];
	}
	
	int32_t eventIndex = [self getEventIndexTableView:tableView indexPath:indexPath];
	
	if (eventIndex < [[EventManager eventKeyArray] count] && 0 <= eventIndex) 
	{
	
		NSString *eventID = [[EventManager eventKeyArray] objectAtIndex:eventIndex];
		NSDictionary *event = [EventManager getObjectWithStringID:eventID];
		self.foodPage.foodDict = [event valueForKey:@"obj"];
		
		[self.navigationController pushViewController:self.foodPage animated:YES];
	}
}

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	int32_t eventIndex = [self getEventIndexTableView:tableView indexPath:indexPath];
	
	if ((([EventManager eventKeyArray].count - ROW_TO_MORE_EVENT_FROM_BOTTOM) <= eventIndex) 
	    && (0 <= eventIndex))
	{
		[self requestOlderEvent];
	}
}

#pragma mark - message

- (void) requestNewerEventHandler
{	
	[self refreshTableView];
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.leftColumn];
}

- (void) requestNewerEvent
{	
	[EventManager requestNewerCount:EVENT_REFRESH_WINDOW withHandler:@selector(requestNewerEventHandler) andTarget:self];
}

- (void) requestOlderEvent
{
	[EventManager requestOlderCount:EVENT_REFRESH_WINDOW withHandler:@selector(refreshTableView) andTarget:self];
}

#pragma mark - util
- (void) refreshTableView
{
	static uint32_t s_lassEventArrayCount = 0;
	uint32_t eventArrayCount = [[EventManager eventKeyArray] count];

	if (s_lassEventArrayCount < eventArrayCount) 
	{
		if ([self.leftColumn respondsToSelector:@selector(reloadData)])
		{
			[self.leftColumn performSelector:@selector(reloadData)];
		}

		if ([self.rightColumn respondsToSelector:@selector(reloadData)])
		{
			[self.rightColumn performSelector:@selector(reloadData)];
		}
		
		self.leftColumn.bounces = YES;
		self.rightColumn.bounces = YES;

		s_lassEventArrayCount = eventArrayCount;
	}
}

#pragma mark - UIScrollViewDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)view
{	
	if (self.leftColumn == view)
	{
		self.rightColumn.contentOffset = view.contentOffset;
	}
	else if (self.rightColumn == view)
	{
		self.leftColumn.contentOffset = view.contentOffset;
	}
	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:view];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)view willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:view];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self requestNewerEvent];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [EventManager isNewerUpdating]; 
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	NSDate *updatedDate = [EventManager lastUpdatedDate];

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
