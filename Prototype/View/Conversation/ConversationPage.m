//
//  ConversationList.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationPage.h"

#import "ConversationListManager.h"
#import "UserInfoPage.h"
#import "ConversationListCell.h"
#import "Util.h"
#import "ConversationDetailPage.h"

const static uint32_t CONVERSATION_REFRESH_WINDOW = 21;

@interface ConversationPage () 
{
	ConversationDetailPage *_detailPage;
}

@property (strong) ConversationDetailPage *detailPage;

@end

@implementation ConversationPage

@synthesize detailPage = _detailPage;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationPage);

#pragma mark - life circle

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];

	if (self) 
	{
		// init ConserSationListManager
		[ConversationListManager class];
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.detailPage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[self class ] updateConversationList];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return [[ConversationListManager keyArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ListCell";
	
	ConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[ConversationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSString *conversationID = [[ConversationListManager keyArray] objectAtIndex:indexPath.row];
	NSDictionary *conversation = [ConversationListManager getConversationWithUser:conversationID];
	
	if (nil != conversation)
	{
		cell.conversationListDict = conversation;
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *conversationID = [[ConversationListManager keyArray] objectAtIndex:indexPath.row];
	NSDictionary *conversation = [ConversationListManager getConversationWithUser:conversationID];
	NSNumber *targetUserID = [conversation valueForKey:@"target"];
	
	if(nil != targetUserID)
	{
		if (nil == self.detailPage)
		{
			ConversationDetailPage *detailPage = [[ConversationDetailPage alloc] init];
			
			self.detailPage = detailPage;
			
			[detailPage release];
		}
		
		self.detailPage.targetUserID = [targetUserID stringValue];
		
		[self.navigationController pushViewController:self.detailPage animated:YES];
	}
}

#pragma mark - class interface

+ (void) updateBage:(NSInteger)unreadMessageCount
{
	if (unreadMessageCount > 0)
	{
		@autoreleasepool 
		{
			NSString *newMessageBadge = [NSString stringWithFormat:@"%d", unreadMessageCount];
			[[[[self getInstnace] navigationController] tabBarItem] setBadgeValue:newMessageBadge];
		}
		
	}
	else
	{
		[[[[self getInstnace] navigationController] tabBarItem] setBadgeValue:nil];
	}
}

+ (void) updateConversationList
{
	[ConversationListManager requestNewerCount:CONVERSATION_REFRESH_WINDOW 
				       withHandler:@selector(reloadData) 
					 andTarget:[[self getInstnace] tableView]];
}

@end
