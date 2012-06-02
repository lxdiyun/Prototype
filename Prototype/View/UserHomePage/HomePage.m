//
//  HomePage.m
//  Prototype
//
//  Created by Adrian Lee on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomePage.h"

#import "UserFoodHistoryHeader.h"
#import "UserFoodMapHeader.h"
#import "UserFoodTargetHeader.h"
#import "ProfileMananger.h"
#import "FoodMapListManager.h"
#import "UserFoodHistoryManager.h"
#import "FollowingListManager.h"
#import "FoodManager.h"
#import "ListCell.h"
#import "Util.h"

typedef enum USER_HOME_PAGE_SECTION_ENUM
{
	USER_INFO = 0x0,
	USER_FOOD_HISTORY = 0x1,
	USER_FOOD_MAP = 0x2,
	USER_PAGE_SECTION_MAX,
// revalute to show target
	USER_FOOD_TARGET = 0xFFF,
	
} USER_HOME_PAGE_SECTION;

@interface HomePage () <FoldDelegate>
{
	NSNumber *_userID;

	UserFoodTargetHeader *_targetHeader;
	UserFoodHistoryHeader *_historyHeader;
	UserFoodMapHeader *_mapHeader;
	UIBarButtonItem *_followButton;
	UIBarButtonItem *_unFollowButton;
	NSUInteger _lastSectionObjectCount[USER_PAGE_SECTION_MAX];
	MapViewPage *_mapPage;
	FoodPage *_foodPage;
}


@property (retain, nonatomic) UserFoodTargetHeader *targetHeader;
@property (retain, nonatomic) UserFoodHistoryHeader *historyHeader;
@property (retain, nonatomic) UserFoodMapHeader *mapHeader;
@property (retain, nonatomic) UIBarButtonItem *followButton;
@property (retain, nonatomic) UIBarButtonItem *unFollowButton;

@end

@implementation HomePage

@synthesize userID = _userID;
@synthesize historyHeader = _historyHeader;
@synthesize targetHeader = _targetHeader;
@synthesize mapHeader = _mapHeader;
@synthesize mapPage = _mapPage;
@synthesize foodPage = _foodPage;
@synthesize followButton = _followButton;
@synthesize unFollowButton = _unFollowButton;

#pragma mark - view control life circle

- (void) dealloc
{
	self.userID = nil;
	self.targetHeader = nil;
	self.historyHeader = nil;
	self.mapHeader = nil;
	self.mapPage = nil;
	self.foodPage = nil;
	self.followButton = nil;
	self.unFollowButton = nil;

	[super dealloc];
}

#pragma mark - Table view data source - cell

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return USER_PAGE_SECTION_MAX;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger objectCount = [self objectCountFor:section];
	
	_lastSectionObjectCount[section] = objectCount;
	
	switch (section) 
	{
		case USER_FOOD_TARGET:
		case USER_FOOD_HISTORY:
			return objectCount;
			break;
			
		default:
			
			return objectCount;
			break;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case USER_INFO:
			return [self getInfoCell];

			break;
		case USER_FOOD_MAP:
			return [self getFoodMapCell:indexPath];
			
			break;
			
		default:
		{
			static NSString *CellIdentifier = @"ListCell";
			ListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (nil == cell)
			{
				cell = [ListCell createFromXIB];
			}
			
			[self config:cell at:indexPath];
			
			return cell;
		}
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case USER_INFO:
			return [self getInfoCell].frame.size.height;
			
			break;
		case USER_FOOD_MAP:
			return DEFAULT_CELL_HEIGHT;
			
			break;
		default:
			return LIST_CELL_HEIGTH;
			break;
	}
}

#pragma mark - Table view data source - header

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case USER_FOOD_TARGET:
			return self.targetHeader;
			
			break;
			
		case USER_FOOD_HISTORY:
			return self.historyHeader;
			
			break;
			
		case USER_FOOD_MAP:
			return self.mapHeader;
			
			break;
			
		default:
			return nil;
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case USER_FOOD_TARGET:
			return self.targetHeader.frame.size.height;
			
			break;
			
		case USER_FOOD_HISTORY:
			return self.historyHeader.frame.size.height;
			
			break;

		case USER_FOOD_MAP:
			return self.mapHeader.frame.size.height;
			
			break;

		default:
			return 0;
			break;
	}
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSUInteger index = indexPath.row;
	NSInteger total = [self objectCountFor:indexPath.section];
	
	
	if ((total - ROW_TO_MORE_FROM_BOTTOM) <= index)
	{
		switch (indexPath.section) 
		{
			case USER_FOOD_TARGET:
				[self requestOlderTarget];
				
				break;
				
			case USER_FOOD_HISTORY:
				[self requestOlderHistory];
	
				break;
				
			case USER_FOOD_MAP:
				[self requestOlderFoodMap];
				
				break;
				
			default:
				break;
		}
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case USER_FOOD_HISTORY:
			[self showFood:indexPath];

			break;
		case USER_FOOD_MAP:
			[self showMap:indexPath];

			break;

		default:
			break;
	}
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case USER_INFO:
			return nil;
			
			break;
			
		default:
			return indexPath;
			break;
	}
}

#pragma mark - Object Manage

- (void) forceRequestUserInfo
{
	[ProfileMananger requestObjectWithNumberID:self.userID 
					andHandler:@selector(requestUserInfo) 
					 andTarget:self];
}

- (void) requestUserInfo
{
	if (nil != self.userID)
	{
		NSDictionary *user = [ProfileMananger getObjectWithNumberID:self.userID];
		
		if (nil != user)
		{
			[self updateGUIWith:user];
		}
		else 
		{
			[self forceRequestUserInfo];
		}
	}
}

- (void) pullToRefreshRequest
{
	[self forceRequestUserInfo];
	[self requestNewestTarget];
	[self requestNewestHistory];
	[self requestNewestFoodMap];
}

- (void) viewWillAppearRequest
{
	[self requestUserInfo];
	[self requestNewerTarget];
	[self requestNewerHistory];
	[self requestNewerFoodMap];
}

- (void) requestOlder
{
	[self requestOlderTarget];
	[self requestOlderHistory];
	[self requestOlderFoodMap];
}

- (void) requestNewestTarget
{
	
}

- (void) requestNewerTarget
{
	
}

- (void) requestOlderTarget
{
	
}

- (void) requestNewestHistory
{
	[UserFoodHistoryManager requestNewestWithListID:[self.userID stringValue] 
					      andCount:REFRESH_WINDOW 
					   withHandler:@selector(reloadHistory) 
					     andTarget:self];
}

- (void) requestNewerHistory
{
	[UserFoodHistoryManager requestNewerWithListID:[self.userID stringValue] 
					     andCount:REFRESH_WINDOW 
					  withHandler:@selector(reloadHistory) 
					    andTarget:self];
}

- (void) requestOlderHistory
{
	[UserFoodHistoryManager requestOlderWithListID:[self.userID stringValue] 
					       andCount:REFRESH_WINDOW 
					    withHandler:@selector(reload) 
					      andTarget:self];
}

- (void) requestNewestFoodMap
{
	[FoodMapListManager requestNewestWithListID:[self.userID stringValue] 
					   andCount:REFRESH_WINDOW 
					withHandler:@selector(reloadFoodMap) 
					  andTarget:self];
}

- (void) requestNewerFoodMap
{
	[FoodMapListManager requestNewerWithListID:[self.userID stringValue] 
					  andCount:REFRESH_WINDOW 
				       withHandler:@selector(reloadFoodMap) 
					 andTarget:self];
}

- (void) requestOlderFoodMap
{
	[FoodMapListManager requestOlderWithListID:[self.userID stringValue] 
					  andCount:REFRESH_WINDOW 
				       withHandler:@selector(reload) 
					 andTarget:self];
}

- (NSUInteger) objectCountFor:(USER_HOME_PAGE_SECTION)section
{
	switch (section) 
	{
		case USER_INFO:
			return 1;
			
			break;
			
		case USER_FOOD_TARGET:
			if (!self.targetHeader.isFolding) 
			{
				return 0;
			}
			
			break;
			
		case USER_FOOD_HISTORY:
			if (!self.historyHeader.isFolding) 
			{
				return [[UserFoodHistoryManager keyArrayForList:[self.userID stringValue]] count];
			}
			
			break;
			
		case USER_FOOD_MAP:
			if (!self.mapHeader.isFolding) 
			{
				return [[FoodMapListManager keyArrayForList:[self.userID stringValue]] count];
			}
			
			break;
			
		default:
			return 0;
			
			break;
	}
	
	return 0;
}

- (NSDictionary *) getObjectFor:(NSIndexPath *)index
{
	switch (index.section) 
	{
		case USER_FOOD_HISTORY:
		{
			NSString *foodID = [[UserFoodHistoryManager keyArrayForList:[self.userID stringValue]] objectAtIndex:index.row]; 
			NSDictionary *food = [FoodManager getObjectWithStringID:foodID];
			
			return food;
		}
			break;

		case USER_FOOD_MAP:
		{
			NSString *mapID = [[FoodMapListManager keyArrayForList:[self.userID stringValue]] objectAtIndex:index.row]; 
			NSDictionary *map = [FoodMapListManager getObject:mapID inList:[self.userID stringValue]];
			
			return map;
		}
			break;
			
		default:
			return nil;
			
			break;
	}
}

- (BOOL) isUpdating
{
	return [ProfileMananger isUpdatingObjectNumberID:self.userID] 
	| [UserFoodHistoryManager isUpdatingWithType:REQUEST_NEWEST 
					  withListID:[self.userID stringValue]]
	| [FoodMapListManager isUpdatingWithType:REQUEST_NEWEST 
				      withListID:[self.userID stringValue]];
}

- (NSDate *) lastUpdateDate
{
	return [UserFoodHistoryManager lastUpdatedDateForList:[self.userID stringValue]];
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		[super initGUI];
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));

		if (nil == self.targetHeader)
		{
			self.targetHeader = [UserFoodTargetHeader createFromXIB];
			self.targetHeader.delegate = self;
		}
		if (nil == self.historyHeader)
		{
			self.historyHeader = [UserFoodHistoryHeader createFromXIB];
			self.historyHeader.delegate = self;
		}
		if (nil == self.mapHeader)
		{
			self.mapHeader = [UserFoodMapHeader createFromXIB];
			self.mapHeader.delegate = self;
		}
		
		if (nil == self.unFollowButton)
		{
			self.unFollowButton = SETUP_BAR_TEXT_BUTTON(@"取消关注", self, @selector(unfollow));
		}
		if (nil == self.followButton)
		{
			self.followButton = SETUP_BAR_TEXT_BUTTON(@"关注", self, @selector(follow));
		}
		
		if (nil == self.mapPage)
		{
			self.mapPage = [[[MapViewPage alloc] init] autorelease];
		}
		if (nil == self.foodPage)
		{
			self.foodPage = [[[FoodPage alloc] init] autorelease];
		}

		for (NSInteger i = 0 ; i < USER_PAGE_SECTION_MAX; ++i)
		{
			_lastSectionObjectCount[i] = 0;
		}
	}
}

- (void) resetGUI
{
	[self.targetHeader resetGUI];
	[self.historyHeader resetGUI];
	[self.mapHeader resetGUI];
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop 
							  animated:NO]; 
}

- (void) updateGUIWith:(NSDictionary *)user
{
	self.title = [user valueForKey:@"nick"];

	if (CHECK_EQUAL(GET_USER_ID(), [user valueForKey:@"id"]))
	{
		self.navigationItem.rightBarButtonItem = nil;
	}
	else 
	{
		[self updateFollowButtonWith:user];
	}
}

- (void) updateFollowButtonWith:(NSDictionary *)user
{
	BOOL isFollowing = [[user valueForKey:@"is_following"] boolValue];
	
	if (isFollowing)
	{
		self.navigationItem.rightBarButtonItem = self.unFollowButton;
		self.unFollowButton.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem = self.followButton;
		self.followButton.enabled = YES;
	}
	
}

- (void) reloadSection:(USER_HOME_PAGE_SECTION)section
{
	@autoreleasepool 
	{
		if ([self objectCountFor:section] != _lastSectionObjectCount[section])
		{
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
				      withRowAnimation:UITableViewRowAnimationNone];
		}
		
		[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	}
}

- (void) reloadTarget
{
	[self reloadSection:USER_FOOD_TARGET];
}

- (void) reloadHistory
{
	[self reloadSection:USER_FOOD_HISTORY];
}

- (void) reloadFoodMap
{
	[self reloadSection:USER_FOOD_MAP];
}

- (void) reload
{
	for (int section = 0; section < USER_PAGE_SECTION_MAX; ++section)
	{
		if ([self objectCountFor:section] != _lastSectionObjectCount[section])
		{
			[self.tableView reloadData];
			
			break;
		}
	}
}

- (void) config:(ListCell *)cell at:(NSIndexPath *)index
{
	@autoreleasepool 
	{
		switch (index.section) 
		{
			case USER_FOOD_TARGET:
			case USER_FOOD_HISTORY:
			{
				NSDictionary *food = [self getObjectFor:index];
				cell.name.text = [food valueForKey:@"name"];
				cell.desc.text = [food valueForKey:@"desc"];
				cell.image.picID = [food valueForKey:@"pic"];
			}
				break;
				
			default:
				break;
		}
	}
}

- (UITableViewCell *) getFoodMapCell:(NSIndexPath *)index
{
	static NSString *CellIdentifier = @"USER_FOOD_MAP_CELL";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
					       reuseIdentifier:CellIdentifier] autorelease];
		UIView* background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		CELL_BORDER(background.layer);
		cell.backgroundView = background;
		cell.textLabel.textColor = [Color tasty];
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	NSDictionary *map = [self getObjectFor:index];
	cell.textLabel.text = [map valueForKey:@"title"];
	cell.detailTextLabel.text = [map valueForKey:@"intro"];
	
	return cell;
}

- (InfoCell *) getInfoCell
{
	LOG(@"Error: should implement in the sub class");
	
	return nil;
}

- (void) showMap:(NSIndexPath *)index
{
	NSDictionary *map = [self getObjectFor:index];
	
	self.mapPage.mapObject = map;
	
	if (CHECK_EQUAL(self.userID, GET_USER_ID()))
	{
		self.mapPage.saveWhenLeaved = YES;
	}
	else 
	{
		self.mapPage.saveWhenLeaved = NO;
	}
	
	[self.navigationController pushViewController:self.mapPage animated:YES];
}

- (void) showFood:(NSIndexPath *)index
{
	NSDictionary *food = [self getObjectFor:index];
	
	self.foodPage.foodID = [food valueForKey:@"id"];
	self.foodPage.hidesBottomBarWhenPushed = YES;
	
	[self.navigationController pushViewController:self.foodPage animated:YES];
}

#pragma mark - FoldDelegate

- (void) fold:(id)sender
{
	if (sender == self.targetHeader)
	{
		[self reloadSection:USER_FOOD_TARGET];
	}
	else if (sender == self.historyHeader)
	{
		[self reloadSection:USER_FOOD_HISTORY];
	}
	else if (sender == self.mapHeader)
	{
		[self reloadSection:USER_FOOD_MAP];
	}
}

#pragma mark - ShowVCDelegate

- (void) showVC:(UIViewController *)vc
{
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - button action

- (void) follow
{
	[FollowingListManager follow:self.userID with:@selector(forceRequestUserInfo) and:self];
	self.followButton.enabled = NO;
}

- (void) unfollow
{
	[FollowingListManager unFollow:self.userID with:@selector(forceRequestUserInfo) and:self];
	self.unFollowButton.enabled = NO;
}

@end
