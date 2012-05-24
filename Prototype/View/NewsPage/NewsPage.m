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
#import "MessageHeader.h"
#import "NoticeHeader.h"
#import "Util.h"
#import "MessageCell.h"
#import "NoticeCell.h"

typedef enum NEWS_SECTION_ENUM
{
	MESSAGE_SECTION = 0x0,
	NOTICE_SECTION = 0x1,
	NEWS_SECTION_MAX
} NEWS_SECTION;

@interface NewsPage () <FoldDelegate>
{	
	FoodPage *_foodPage;
	UserHomePage *_userPage;
	ConversationDetailPage *_conversationPage;
	NSInteger _unreadMessageCount;
	NSInteger _unreadNoticeCount;
	NSInteger _displayedNoticeCount;
	MessageHeader *_messageHeader;
	NoticeHeader *_noticeHeader;
	NSUInteger _lastSectionObjectCount[NEWS_SECTION_MAX];
}

@property (strong, nonatomic) FoodPage *foodPage;
@property (strong, nonatomic) UserHomePage *userPage;
@property (strong, nonatomic) ConversationDetailPage *conversationPage;
@property (assign, nonatomic) NSInteger unreadMessageCount;
@property (assign, nonatomic) NSInteger unreadNoticeCount;
@property (assign, nonatomic) NSInteger displayedNoticeCount;
@property (strong, nonatomic) MessageHeader *messageHeader;
@property (strong, nonatomic) NoticeHeader *noticeHeader;


@end

@implementation NewsPage

@synthesize foodPage = _foodPage;
@synthesize userPage = _userPage;
@synthesize conversationPage = _conversationPage;
@synthesize unreadMessageCount = _unreadMessageCount;
@synthesize unreadNoticeCount = _unreadNoticeCount;
@synthesize messageHeader = _messageHeader;
@synthesize noticeHeader = _noticeHeader;
@synthesize displayedNoticeCount = _displayedNoticeCount;

#pragma mark - singleton

DEFINE_SINGLETON(NewsPage);

#pragma mark - life circle

- (void) dealloc
{
	self.foodPage = nil;
	self.userPage = nil;
	self.conversationPage = nil;

	[super dealloc];
}

#pragma mark - view life circle

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self cleanNews];
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
	
	switch (section) 
	{
		case MESSAGE_SECTION:
		{
			if (self.messageHeader.isFolding)
			{
				return 0;
			}
		}
			break;
			
		case NOTICE_SECTION:
		{
			if (self.noticeHeader.isFolding)
			{
				return 0;
			}
		}
			break;
			
		default:
			
			
			break;
	}
	
	return objectCount;
}

- (CGFloat) tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return DEFAULT_CELL_HEIGHT;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch (indexPath.section) 
	{
		case MESSAGE_SECTION:
		{
			return [self messageCellFor:indexPath];
		}
			
			break;
		case NOTICE_SECTION:
		{
			return [self noticeCellFor:indexPath];
		}
			
			break;
	}
	
	return nil;
}

#pragma mark - table view data source - header

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case MESSAGE_SECTION:
			return self.messageHeader.frame.size.height;

			break;
			
		case NOTICE_SECTION:
			return self.noticeHeader.frame.size.height;
			
			break;
			
		default:
			return 0;
			
			break;
	}
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case MESSAGE_SECTION:
			return self.messageHeader;
			
			break;
			
		case NOTICE_SECTION:
			return self.noticeHeader;
			
			break;
			
		default:
			return nil;
			
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
				[self requestOlderMessage];
				
				break;
				
			case NOTICE_SECTION:
				[self requestOlderNotice];
				
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

- (void) cleanNews
{
	[NotificationManager reset];
	
	self.displayedNoticeCount = 0;
	
	[self reload];
	
	[self updateBage];

	[self resetGUI];
}

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
	[self requestNewestMessage];
	[self requestNewestNotice];
	
	self.displayedNoticeCount = self.unreadNoticeCount;
	self.unreadNoticeCount = 0;
	[self updateNoticeHeader];
}

- (void) viewWillAppearRequest
{
	[self requestNewerMessage];
	[self requestNewestNotice];
	
	self.displayedNoticeCount = self.unreadNoticeCount;
	self.unreadNoticeCount = 0;
	[self updateNoticeHeader];
	
	[self reload];
}

- (void) requestOlder
{
	// done in - (void) tableView:(UITableView *)tableView 
	// willDisplayCell:(UITableViewCell *)cell 
	// forRowAtIndexPath:(NSIndexPath *)indexPath
}

- (void) requestNewestNotice
{
	[NotificationManager requestNewestCount:REFRESH_WINDOW withHandler:@selector(reloadNotice) andTarget:self];
}

- (void) requestNewerNotice
{
	[NotificationManager requestNewerCount:REFRESH_WINDOW withHandler:@selector(reloadNotice) andTarget:self];
}

- (void) requestOlderNotice
{
	[NotificationManager requestOlderCount:REFRESH_WINDOW withHandler:@selector(reload) andTarget:self];
}

- (void) requestNewestMessage
{
	[ConversationListManager requestNewestCount:REFRESH_WINDOW withHandler:@selector(reloadMessage) andTarget:self];
}

- (void) requestNewerMessage
{
	[ConversationListManager requestNewerCount:REFRESH_WINDOW withHandler:@selector(reloadMessage) andTarget:self];
}

- (void) requestOlderMessage
{
	[ConversationListManager requestOlderCount:REFRESH_WINDOW withHandler:@selector(reload) andTarget:self];
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
		
		self.navigationItem.leftBarButtonItem = nil;
		
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
		
		if (nil == self.messageHeader)
		{
			self.messageHeader = [MessageHeader createFromXIB];
			self.messageHeader.delegate = self;
		}
		
		if (nil == self.noticeHeader) 
		{
			self.noticeHeader = [NoticeHeader createFromXIB];
			self.noticeHeader.delegate = self;
		}
		
		[self resetGUI];
	}

}

- (void) resetGUI
{
	[self.messageHeader resetGUI];
	[self.noticeHeader resetGUI];
	
	for (NSInteger i = 0 ; i < NEWS_SECTION_MAX; ++i)
	{
		_lastSectionObjectCount[i] = 0;
	}
}

- (void) reloadSection:(NEWS_SECTION)section
{
	@autoreleasepool 
	{

		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
			      withRowAnimation:UITableViewRowAnimationNone];
		
	}
}

- (void) reloadMessage
{
	[self reloadSection:MESSAGE_SECTION];
}

- (void) reloadNotice
{
	[self reloadSection:NOTICE_SECTION];
	
	[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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

- (void) updateNoticeHeader
{
	NSInteger totalUnreadCount = self.displayedNoticeCount + self.unreadNoticeCount;

	if (0 < totalUnreadCount)
	{
		self.noticeHeader.unread.text = [NSString stringWithFormat:@"%d条", 
						 totalUnreadCount];
	}
	else 
	{
		self.noticeHeader.unread.text = nil;
	}
}

- (void) updateBage
{
	NSInteger totalUnread = self.unreadNoticeCount + self.unreadMessageCount + self.displayedNoticeCount;
	
	if (totalUnread > 0)
	{
		@autoreleasepool 
		{
			NSString *newBadge = [NSString stringWithFormat:@"%d", totalUnread];
			[self.navigationController.tabBarItem setBadgeValue:newBadge];
		}
		
	}
	else
	{
		[self.navigationController.tabBarItem setBadgeValue:nil];
	}
}

- (void) setUnreadMessageCount:(NSInteger)unreadMessageCount
{
	_unreadMessageCount = unreadMessageCount;
	
	if (0 < _unreadMessageCount)
	{
		self.messageHeader.unread.text = [NSString stringWithFormat:@"%d条", _unreadMessageCount];
	}
	else 
	{
		self.messageHeader.unread.text = nil;
	}
}

+ (void) setUnreadMessageCount:(NSInteger)count
{
	[[self getInstnace] setUnreadMessageCount:count];
	
	[[self getInstnace]  updateBage];
}

+ (void) setUnNoticeCount:(NSInteger)count
{
	[[self getInstnace] setUnreadNoticeCount:count];
	
	[[self getInstnace]  updateBage];
}

+ (void) updateMessage
{
	[[self getInstnace] requestNewerMessage];
}

- (UITableViewCell *) noticeCellFor:(NSIndexPath *)index
{
	static NSString *CellIdentifier = @"NoticeCell";
	
	NSDictionary *notice = [self noticeFor:index];	
	NoticeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [NoticeCell createFromXIB];
	}
	
	cell.noticeObject = notice;
	
	return cell;
}

- (UITableViewCell *) messageCellFor:(NSIndexPath *)index
{
	static NSString *CellIdentifier = @"MessageCell";
	
	NSDictionary *message = [self messageFor:index];
	MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [MessageCell createFromXIB];
	}
	
	cell.conversationListDict = message;
	
	return cell;
}

#pragma mark - FoldDelegate

- (void) fold:(id)sender
{
	if (sender == self.messageHeader)
	{
		[self reloadMessage];
	}
	else if (sender == self.noticeHeader)
	{
		[self reloadNotice];
	}
}

@end
