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

const static NSUInteger REFRESH_WINDOW = 8;
const static NSUInteger ROW_TO_MORE_FROM_BOTTOM = 5;

typedef enum USER_HOME_PAGE_SECTION_ENUM
{
	USER_INFO = 0x0,
	USER_FOOD_TARGET = 0x1,
	USER_FOOD_HISTORY = 0x2,
	USER_FOOD_MAP = 0x3,
	USER_PAGE_SECTION_MAX
	
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

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];

	if (nil != self) 
	{
		@autoreleasepool 
		{
		}
	}

	return self;
}

- (void) dealloc
{
	self.userID = nil;
	self.targetHeader = nil;
	self.historyHeader = nil;
	self.mapHeader = nil;
	self.mapPage = nil;
	self.foodPage = nil;

	[super dealloc];
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	HANDLE_MEMORY_WARNING(self);
}

- (void) back
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - view life circle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self initGUI];
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
	
	[self requestUserInfo];
	[self requestNewerTarget];
	[self requestNewerHistory];
	[self requestNewerFoodMap];
	
	[self reloadAll];
}

#pragma mark - Table view data source - cell

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return USER_PAGE_SECTION_MAX;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger objectCount = [self getObjectCountForSection:section];
	
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
	NSInteger total = [self getObjectCountForSection:indexPath.section];
	
	
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

- (void) requestNewerTarget
{
	
}

- (void) requestOlderTarget
{
	
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
					    withHandler:@selector(reloadAll) 
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
				       withHandler:@selector(reloadAll) 
					 andTarget:self];
}

- (NSUInteger) getObjectCountForSection:(USER_HOME_PAGE_SECTION)section
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

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
		self.tableView.backgroundColor = [Color brown];

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

		for (NSInteger i =0 ; i < USER_PAGE_SECTION_MAX; ++i)
		{
			_lastSectionObjectCount[i] = 0;
		}
	}
}

- (void) restGUI
{
	[self.targetHeader resetGUI];
	[self.historyHeader resetGUI];
	[self.mapHeader resetGUI];
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop 
							  animated:NO]; 
}

- (void) updateGUIWith:(NSDictionary *)user
{
	if (CHECK_EQUAL(GET_USER_ID(), [user valueForKey:@"id"]))
	{
		self.title = @"我的主页";
		self.navigationItem.rightBarButtonItem = nil;
	}
	else 
	{
		self.title = [user valueForKey:@"nick"];
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
		if ([self getObjectCountForSection:section] != _lastSectionObjectCount[section])
		{
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
				      withRowAnimation:UITableViewRowAnimationNone];
		}
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

- (void) reloadAll
{
	[self.tableView reloadData];
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
		background.backgroundColor = [Color lightyellow];
		CELL_BORDER(background.layer);
		cell.backgroundView = background;
		cell.textLabel.textColor = [Color tasty];
		cell.textLabel.backgroundColor = [Color lightyellow];
		cell.detailTextLabel.backgroundColor = [Color lightyellow];
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
	
	self.foodPage.foodObject = food;
	
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

- (void) followResultHandler:(NSDictionary *)result
{
	BOOL followUpdated = [[result valueForKey:@"result"] boolValue];
	
	if (followUpdated)
	{
		[self forceRequestUserInfo];
	}
}

- (void) follow
{
	[FollowingListManager follow:self.userID with:@selector(followResultHandler:) and:self];
	self.followButton.enabled = NO;
}

- (void) unfollow
{
	[FollowingListManager unFollow:self.userID with:@selector(followResultHandler:) and:self];
	self.unFollowButton.enabled = NO;
}

@end
