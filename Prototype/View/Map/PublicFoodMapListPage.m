//
//  FoodMapListPage.m
//  Prototype
//
//  Created by Adrian Lee on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PublicFoodMapListPage.h"

#import "PublicFoodMapListManager.h"
#import "Util.h"
#import "MapViewPage.h"
#import "LoginManager.h"

const static uint32_t MAP_LIST_REFRESH_WINDOW = 21;
const static uint32_t ROW_TO_MORE_MAP_LIST_FROM_BOTTOM = 8;

@interface PublicFoodMapListPage ()
{
	MapViewPage *_mapView;
}

@property (strong) MapViewPage *detailMap;

@end

@implementation PublicFoodMapListPage

@synthesize detailMap = _mapView;

#pragma mark - singleton

DEFINE_SINGLETON(PublicFoodMapListPage);

#pragma mark - life cirlce

- (void) dealloc
{
	self.detailMap = nil;

	[super dealloc];
}

#pragma mark - view life cirlce

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self requestNewer];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[PublicFoodMapListManager keyArray] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"USER_FOOD_MAP_CELL";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
					       reuseIdentifier:CellIdentifier] autorelease];
		UIView* background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		background.backgroundColor = [Color lightyellow];
		CELL_BORDER(background.layer);
		cell.backgroundView = background;
		cell.textLabel.textColor = [Color tasty];
		cell.textLabel.backgroundColor = [Color lightyellow];
		cell.detailTextLabel.backgroundColor = [Color lightyellow];
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	NSDictionary *map = [self getObjectFor:indexPath];
	cell.textLabel.text = [map valueForKey:@"title"];
	cell.detailTextLabel.text = [map valueForKey:@"intro"];
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return DEFAULT_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool
	{
		if (nil == self.detailMap)
		{
			self.detailMap = [[[MapViewPage alloc] init] autorelease];
		}
		
		NSDictionary *foodMap = [self getObjectFor:indexPath];

		self.detailMap.mapObject = foodMap;

		[self.navigationController pushViewController:self.detailMap animated:YES];
	}
}

#pragma mark - object manage

- (void) requestNewer
{
	[PublicFoodMapListManager requestNewerCount:REFRESH_WINDOW 
				    withHandler:@selector(reload) 
				      andTarget:self];
}

- (void) requestOlder
{
	[PublicFoodMapListManager requestOlderCount:REFRESH_WINDOW
				    withHandler:@selector(reload) 
				      andTarget:self];
}

- (BOOL) isUpdating
{
	return [PublicFoodMapListManager isNewerUpdating];
}

- (NSDate* ) lastUpdateDate
{
	return [PublicFoodMapListManager lastUpdatedDate];
}

- (NSDictionary *) getObjectFor:(NSIndexPath *)index
{
	NSArray *keyArray = [PublicFoodMapListManager keyArray];
	NSString *mapkey = [keyArray objectAtIndex:index.row];
	NSDictionary *foodMap = [PublicFoodMapListManager getObjectWithStringID:mapkey];
	
	return foodMap;
}

#pragma mark - class interface

+ (void) reloadData
{
	[[[self getInstnace] tableView] reloadData];
}

@end
