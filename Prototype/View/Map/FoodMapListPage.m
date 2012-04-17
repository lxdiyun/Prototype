//
//  FoodMapListPage.m
//  Prototype
//
//  Created by Adrian Lee on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodMapListPage.h"

#import "FoodMapListManager.h"
#import "Util.h"
#import "MapViewPage.h"
#import "LoginManager.h"

const static uint32_t MAP_LIST_REFRESH_WINDOW = 21;
const static uint32_t ROW_TO_MORE_MAP_LIST_FROM_BOTTOM = 8;

@interface FoodMapListPage ()
{
	NSString *_loginUserID;
	MapViewPage *_mapView;
}

@property (strong) NSString *loginUserID;
@property (strong) MapViewPage *mapView;

@end

@implementation FoodMapListPage

@synthesize loginUserID = _loginUserID;
@synthesize mapView = _mapView;

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];

	if (self) 
	{
		// Custom initialization
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	self.loginUserID = nil;
	self.mapView = nil;

	[super viewDidUnload];
}

- (void) requestFoodNewerMapList
{
	self.loginUserID = [GET_USER_ID() stringValue];
	
	if (nil != self.loginUserID)
	{
		[FoodMapListManager requestNewerWithListID:self.loginUserID 
						  andCount:MAP_LIST_REFRESH_WINDOW 
					       withHandler:@selector(reloadData) 
						 andTarget:self.tableView];
	}
	else 
	{
		[LoginManager requestWithHandler:@selector(requestFoodNewerMapList) andTarget:self];
	}
}

- (void) requestFoodOlderMapList
{
	self.loginUserID = [GET_USER_ID() stringValue];
	
	if (nil != self.loginUserID)
	{
		[FoodMapListManager requestOlderWithListID:self.loginUserID 
						  andCount:MAP_LIST_REFRESH_WINDOW 
					       withHandler:@selector(reloadData) 
						 andTarget:self.tableView];
	}
	else 
	{
		[LoginManager requestWithHandler:@selector(requestFoodOlderMapList) andTarget:self];
	}
}

- (void) requestMiddleMapList:(NSString *)mapID
{
	self.loginUserID = [GET_USER_ID() stringValue];
	
	if (nil != self.loginUserID)
	{
		[FoodMapListManager requestMiddle:mapID 
					 inListID:self.loginUserID 
					 andCount:MAP_LIST_REFRESH_WINDOW 
				      withHandler:nil 
					andTarget:nil];
	}
	else 
	{
		return;
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self requestFoodNewerMapList];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{

	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (nil != self.loginUserID)
	{
		return [[FoodMapListManager keyArrayForList:self.loginUserID] count];
	}
	else 
	{
		[LoginManager requestWithHandler:@selector(reloadData) andTarget:self];

		return 0;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	@autoreleasepool 
	{
		NSArray *keyArray = [FoodMapListManager keyArrayForList:self.loginUserID];
		NSString *mapkey = [keyArray objectAtIndex:indexPath.row];
		NSDictionary *foodMap = [FoodMapListManager getObject:mapkey inList:self.loginUserID];

		cell.textLabel.text = [foodMap valueForKey:@"title"];
		cell.detailTextLabel.text = [foodMap valueForKey:@"intro"];
	}

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool
	{
		if (nil == self.mapView)
		{
			self.mapView = [[[MapViewPage alloc] init] autorelease];
		}

		NSArray *keyArray = [FoodMapListManager keyArrayForList:self.loginUserID];
		NSString *mapkey = [keyArray objectAtIndex:indexPath.row];
		NSDictionary *foodMap = [FoodMapListManager getObject:mapkey inList:self.loginUserID];

		self.mapView.mapObject = foodMap;
		
		[self requestMiddleMapList:[[foodMap valueForKey:@"id"] stringValue]];

		[self.navigationController pushViewController:self.mapView animated:YES];
	}
}

@end
