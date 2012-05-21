//
//  NewsPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsPage.h"

#import "NotificationManager.h"
#import "ConversationListManager.h"
#import "FoodPage.h"
#import "ConversationDetailPage.h"
#import "UserHomePage.h"
#import "Util.h"

typedef enum NEWS_SECTION_ENUM
{
	MESSAGE_SECTION = 0x0,
	NOTICE_SECTION = 0x1,
	NEWS_SECTION_MAX
} NEWS_SECTION;

@interface NewsPage ()
{
	NSInteger _lastSectionObjectCount[NEWS_SECTION_MAX];
	
	FoodPage *_foodPage;
	UserHomePage *_userPage;
	ConversationDetailPage *_conversationPage;
}

@property (strong, nonatomic) FoodPage *foodPage;
@property (strong, nonatomic) UserHomePage *userPage;
@property (strong, nonatomic) ConversationDetailPage *conversationPage;

@end

@implementation NewsPage

@synthesize foodPage = _foodPage;
@synthesize userPage = _userPage;
@synthesize conversationPage = _conversationPage;

#pragma mark - singleton

DEFINE_SINGLETON(NewsPage);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (self)
	{
		// init daemon messages
		[NotificationManager class];
		[ConversationListManager class];
	}
	
	return self;
}

- (void) dealloc
{
	self.foodPage = nil;
	self.userPage = nil;
	self.conversationPage = nil;

	[super dealloc];
}

#pragma mark - table view data source - cell

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return NEWS_SECTION_MAX;
}

- (NSInteger) tableView:(UITableView *)tableView 
  numberOfRowsInSection:(NSInteger)section
{
	NSInteger objectCount = [self objectCountFor:section];
	
	_lastSectionObjectCount[section] = objectCount;
	
	return objectCount;
}

- (CGFloat) tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return DEFAULT_CELL_HEIGHT;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"NewsCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
					      reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSDictionary *cellObject = [self objectFor:indexPath];
	
	
	switch (indexPath.section) 
	{
		case MESSAGE_SECTION:
		{
			cell.textLabel.text = [cellObject valueForKey:@"created_on"];
			cell.detailTextLabel.text = [cellObject valueForKey:@"msg"];
		}
			
			break;
		case NOTICE_SECTION:
		{
			cell.textLabel.text = [cellObject valueForKey:@"msg"];
		}
			
			break;
		
			break;
	}
	
	return cell;
}

#pragma mark - table view data source - header

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case MESSAGE_SECTION:
			return @"私信";
			break;
		case NOTICE_SECTION:
			return @"通知";
			break;
		default:
			return [NSString stringWithFormat:@"%d", section];
			break;
	}
}

#pragma mark - table view delegate

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
			case MESSAGE_SECTION:
				[ConversationListManager requestOlderCount:REFRESH_WINDOW 
							       withHandler:@selector(reload) 
								 andTarget:self];
				
				break;
				
			case NOTICE_SECTION:
				[NotificationManager requestOlderCount:REFRESH_WINDOW 
							   withHandler:@selector(reload) 
							     andTarget:self];
				
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
		case MESSAGE_SECTION:
			[self showMessage:indexPath];
			
			break;
		case NOTICE_SECTION:
			[self showNotice:indexPath];
			
			break;
			
		default:
			break;
	}
}

#pragma mark - object manage

- (NSInteger) objectCountFor:(NEWS_SECTION)section
{
	switch (section) 
	{
		case MESSAGE_SECTION:
			return [[ConversationListManager keyArray] count];
			
			break;
		
		case NOTICE_SECTION:
			return [[NotificationManager keyArray] count];
			
			break;
		default:
			return 0;
			
			break;
	}
}

- (NSDictionary *) objectFor:(NSIndexPath *)index
{
	switch (index.section) 
	{
		case MESSAGE_SECTION:
			return [self messageFor:index];
			
			break;
			
		case NOTICE_SECTION:
			return [self noticeFor:index];
			
			break;
		default:
			return nil;
			
			break;
	}
}

- (NSDictionary *) messageFor:(NSIndexPath *)index
{
	NSString *ID = [[ConversationListManager keyArray] objectAtIndex:index.row];
	
	return [ConversationListManager getConversationWith:ID];
}

- (NSDictionary *) noticeFor:(NSIndexPath *)index
{
	NSString *ID = [[NotificationManager keyArray] objectAtIndex:index.row];
	
	return [NotificationManager getNotificationWith:ID];
}

- (void) pullToRefreshRequest
{
	[ConversationListManager requestNewestCount:REFRESH_WINDOW withHandler:@selector(reloadMessage) andTarget:self];
	[NotificationManager requestNewestCount:REFRESH_WINDOW withHandler:@selector(reloadNotice) andTarget:self];
}

- (void) requestNewer
{
	[ConversationListManager requestNewerCount:REFRESH_WINDOW withHandler:@selector(reloadMessage) andTarget:self];
	[NotificationManager requestNewerCount:REFRESH_WINDOW withHandler:@selector(reloadNotice) andTarget:self];
}

- (void) requestOlder
{
}

- (BOOL) isUpdating
{
	return [ConversationListManager isNewestUpdating] | [NotificationManager isNewestUpdating];
}

- (NSDate* ) lastUpdateDate
{
	NSDate * date = [ConversationListManager lastUpdatedDate];
	
	if (nil == date)
	{
		date = [NotificationManager lastUpdatedDate];
	}
	
	return date;
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		[super initGUI];
		
		for (NSInteger section; section < NEWS_SECTION_MAX; ++section)
		{
			_lastSectionObjectCount[section] = 0;
		}
		
		if (nil == self.foodPage)
		{
			self.foodPage = [[[FoodPage alloc] init] autorelease];
		}
		
		if (nil == self.userPage)
		{
			self.userPage = [[[UserHomePage alloc] init] autorelease];
		}
		
		if (nil == self.conversationPage)
		{
			self.conversationPage = [[[ConversationDetailPage alloc] init] autorelease];
		}
	}

}

- (void) reloadSection:(NEWS_SECTION)section
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

- (void) reloadMessage
{
	[self reloadSection:MESSAGE_SECTION];
}

- (void) reloadNotice
{
	[self reloadSection:NOTICE_SECTION];
}

- (void) reload
{
	for (int section = 0; section < NEWS_SECTION_MAX; ++section)
	{
		if ([self objectCountFor:section] != _lastSectionObjectCount[section])
		{
			[self.tableView reloadData];
			
			break;
		}
	}
}

- (void) showMessage:(NSIndexPath *)index
{
	NSDictionary *conversation = [self objectFor:index];
	NSNumber *targetUserID = [conversation valueForKey:@"target"];
	
	self.conversationPage.targetUserID = [targetUserID stringValue];
	
	[self.navigationController pushViewController:self.conversationPage animated:YES];
}

- (void) showNotice:(NSIndexPath *)index
{
	NSDictionary *notice = [self objectFor:index];
	NSString *noticeType = [notice valueForKey:@"msg_type"];
	
	if (CHECK_EQUAL(noticeType, @"follow"))
	{
		self.userPage.userID = [notice valueForKey:@"obj"];
		[self.userPage resetGUI];
		
		[self.navigationController pushViewController:self.userPage animated:YES];
	}
	else if (CHECK_EQUAL(noticeType, @"comment"))
	{
		self.foodPage.foodID = [notice valueForKey:@"obj"];
		
		[self.navigationController pushViewController:self.foodPage animated:YES];
	}
	
	
}


@end
