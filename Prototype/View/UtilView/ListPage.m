//
//  UserListPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListPage.h"

#import "Util.h"
#import "PullToRefreshV.h"

@interface ListPage () <EGORefreshTableHeaderDelegate>
{
	PullToRefreshV *_refreshHeader;
	NSInteger _lastRowCount;
}

@property (strong, nonatomic) PullToRefreshV *refreshHeader;
@property (assign, nonatomic) NSInteger lastRowCount;

@end

@implementation ListPage

@synthesize refreshHeader = _refreshHeader;
@synthesize lastRowCount = _lastRowCount;

#pragma mark - view controller life circle

- (id) init
{
	self = [super initWithStyle:UITableViewStylePlain];

	if (nil != self) 
	{
		self.lastRowCount = 0;
	}
	
	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	HANDLE_MEMORY_WARNING(self);
}

- (void) dealloc
{
	self.refreshHeader = nil;
	[super dealloc];
}

#pragma mark - view life circle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
	
	if (nil == self.refreshHeader) 
	{
		// init fresh header
		CGRect frame = CGRectMake(0.0f, 
					  0.0f - self.tableView.bounds.size.height, 
					  self.tableView.frame.size.width,
					  self.tableView.bounds.size.height);
		
		PullToRefreshV *view = [[PullToRefreshV alloc] initWithFrame:frame
							      arrowImageName:@"blackArrow.png" 
								   textColor:[UIColor blackColor]
								   indicator:UIActivityIndicatorViewStyleGray];
		view.delegate = self;
		self.refreshHeader = view;
		[view release];
	}

	[self.view addSubview:self.refreshHeader];
	
	self.tableView.backgroundColor = [Color lightyellow];
	self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self requestNewer];
	
	[self.refreshHeader refreshLastUpdatedDate];
	
	[self reload];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView 
  numberOfRowsInSection:(NSInteger)section
{
	LOG(@"Error: need to implement in the sub class");
	
	return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView 
	  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LOG(@"Error: need to implement in the sub class");
	
	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LOG(@"Error: need to implement in the sub class");
	
	return 0;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LOG(@"Error: need to implement in the sub class");
}

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = indexPath.row;
	NSInteger total = [self tableView:self.tableView numberOfRowsInSection:1];
	
	
	if ((total - ROW_TO_MORE_FROM_BOTTOM) <= index)
	{
		[self requestOlder];
	}
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)view
{	
	[self.refreshHeader egoRefreshScrollViewDidScroll:view];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)view willDecelerate:(BOOL)decelerate
{
	
	[self.refreshHeader egoRefreshScrollViewDidEndDragging:view];
}

#pragma mark - object manage

- (void) requestNewer
{
	LOG(@"Error: need to implement in the sub class");
}

- (void) requestOlder
{
	LOG(@"Error: need to implement in the sub class");
}

- (BOOL) isUpdating
{
	LOG(@"Error: need to implement in the sub class");
	return NO;
}

- (NSDate *) lastUpdateDate
{
	LOG(@"Error: need to implement in the sub class");
	return nil;
}

#pragma mark - GUI

- (void) back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) reload
{
	NSInteger newRowCount = [self tableView:self.tableView numberOfRowsInSection:1];
	
	if (newRowCount != self.lastRowCount)
	{
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] 
			      withRowAnimation:UITableViewRowAnimationFade];
		
		self.lastRowCount = newRowCount;
	}

	[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void) egoRefreshTableHeaderDidTriggerRefresh:(PullToRefreshV *)view
{
	[self requestNewer];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(PullToRefreshV *)view
{
	return [self isUpdating]; 
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(PullToRefreshV *)view
{
	NSDate *updateDate = [self lastUpdateDate];
	
	if (nil != updateDate)
	{
		return updateDate;
	}
	else
	{
		return [NSDate date];
	}
}

@end
