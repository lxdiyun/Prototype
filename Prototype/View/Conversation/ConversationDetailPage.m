//
//  ConversationDetail.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationDetailPage.h"

#import "ConversationManager.h"
#import "DetailCell.h"
#import "TextInputer.h"
#import "ProfileMananger.h"
#import "Util.h"
#import "ConversationPage.h"

const static uint32_t CONVERSATION_DETAIL_REFRESH_WINDOW = 21;
const static uint32_t ROW_TO_MORE_CONVERSATION = 2;

@interface  ConversationDetailPage  ()  <TextInputerDeletgate>
{
	NSString *_targetUserID;
	TextInputer *_inputer;
	UINavigationController *_navco;
	BOOL _canUpdateOlder;
	BOOL _appear;
}
@property (strong) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@property (assign) BOOL canUpdateOlder;
@property (assign) BOOL appear;

- (void) updateNewerConversation;
- (void) updateOlderConversation;
- (void) refreshTableView;
- (void) updateTitle;
@end

@implementation ConversationDetailPage

@synthesize targetUserID = _targetUserID;
@synthesize inputer = _inputer;
@synthesize navco = _navco;
@synthesize canUpdateOlder = _canUpdateOlder;
@synthesize appear = _appear;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationDetailPage);

#pragma mark - life circle

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
	{
		
	}
	return self;
}

- (void) didReceiveMemoryWarning
{	
	if (self.inputer.appearing)
	{
		[self cancelWithTextInputer:self.inputer];
	}

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	UIView* superview = self.view.superview;
	
	if (superview == nil)
	{
		NSMutableArray *allViewControllers =  [self.navigationController.viewControllers mutableCopy];
		[allViewControllers removeObjectIdenticalTo: self];
		self.navigationController.viewControllers = allViewControllers;
		
		[allViewControllers release];
	}
}

#pragma mark - View lifecycle

- (void) back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	@autoreleasepool 
	{
		self.navigationItem.rightBarButtonItem = SETUP_BAR_BUTTON([UIImage imageNamed:@"comIcon.png"], 
									  self, 
									  @selector(inputMessage:));
		
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (void) resetCanUpdateOlder
{
	self.canUpdateOlder = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self updateTitle];
	self.canUpdateOlder = NO;
	
	if (nil != self.targetUserID)
	{
		[self updateNewerConversation];
	}
	
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.appear = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	self.appear = NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (nil != self.targetUserID)
	{
		return [[ConversationManager keyArrayForList:self.targetUserID] count];
	}
	
	return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[DetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSInteger maxCellIndex = [[ConversationManager keyArrayForList:self.targetUserID] count] - 1;
	NSString *conversationID = [[ConversationManager keyArrayForList:self.targetUserID] objectAtIndex:maxCellIndex - indexPath.row];
	NSDictionary *messageDict = [ConversationManager getObject:conversationID inList:self.targetUserID];
	
	cell.conversationDict = messageDict;
	
	return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row <= ROW_TO_MORE_CONVERSATION)
	{
		[self updateOlderConversation];
	}
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger maxCellIndex = [[ConversationManager keyArrayForList:self.targetUserID] count] - 1;

	NSString *conversationID = [[ConversationManager keyArrayForList:self.targetUserID] objectAtIndex:maxCellIndex - indexPath.row];
	
	NSDictionary *conversation = [ConversationManager getObject:conversationID inList:self.targetUserID];
	
	return [DetailCell cellHeightForConversation:conversation 
					forCellWidth:self.tableView.frame.size.width];
}

#pragma mark - action and interface

- (void) inputMessage:(id)sender
{
	if (nil == self.inputer)
	{
		self.inputer = [[[TextInputer alloc] init] autorelease];
		self.inputer.delegate = self;
		[self.inputer redraw];
	}
	
	if (nil == self.navco)
	{
		self.navco = [[[UINavigationController alloc] initWithRootViewController:self.inputer] autorelease];
		CONFIG_NAGIVATION_BAR(self.navco.navigationBar);
		self.inputer.title = @"发送私信";
	}
	
	[self presentModalViewController:self.navco animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) newMessageHandler:(id)result
{
	[ConversationManager requestNewerWithListID:self.targetUserID 
					   andCount:CONVERSATION_DETAIL_REFRESH_WINDOW 
					withHandler:@selector(refreshTableView) 
					  andTarget:self];
	[self refreshTableView];	
}

- (void) updateNewerConversation
{
	[ConversationManager requestNewerWithListID:self.targetUserID 
					   andCount:CONVERSATION_DETAIL_REFRESH_WINDOW 
					withHandler:@selector(updateNewerConversationHandler) 
					  andTarget:self];
}

- (void) checkUnreadMesssage
{
	NSInteger oldestKey = [ConversationManager oldestKeyForList:self.targetUserID];
	NSString *oldestID = [[NSString alloc] initWithFormat:@"%d", oldestKey]; 
	NSDictionary *oldestConversation = [ConversationManager getObject:oldestID  inList:self.targetUserID];
	BOOL unreadFlag = [[oldestConversation valueForKey:@"is_read"] boolValue];
	
	if (unreadFlag)
	{
		// may has unread messages, request for them
		[self updateOlderConversation];
	}
	
	[oldestID release];
}

- (void) updateNewerConversationHandler
{	
	[self checkUnreadMesssage];

	[self refreshTableView];

	[self performSelector:@selector(resetCanUpdateOlder) withObject:nil afterDelay:8.0];
}

- (void) updateOlderConversationHandler
{
	static uint32_t lastOldestID = 0;
	uint32_t currentOldestID = [ConversationManager oldestKeyForList:self.targetUserID];

	if (lastOldestID == currentOldestID)
	{
		self.canUpdateOlder = NO;
	}
	else
	{
		lastOldestID = currentOldestID;
	}
	
	[self checkUnreadMesssage];
	
	[self.tableView reloadData];
}

- (void) updateOlderConversation
{
	if (self.canUpdateOlder)
	{

		[ConversationManager requestOlderWithListID:self.targetUserID 
						   andCount:CONVERSATION_DETAIL_REFRESH_WINDOW 
						withHandler:@selector(updateOlderConversationHandler) 
						  andTarget:self];
	}
}

- (void) refreshTableView
{
	@autoreleasepool 
	{
		[self.tableView reloadData];
		
		NSInteger maxCellIndex = [[ConversationManager keyArrayForList:self.targetUserID] count] - 1;
		
		BOOL hasUnreadMesasage  = [ConversationManager hasUnreadMessageforUser:self.targetUserID];
		
		if (hasUnreadMesasage)
		{
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxCellIndex inSection:0] 
					      atScrollPosition:UITableViewScrollPositionBottom 
						      animated:YES];
			[ConversationPage updateConversationList];
			[ConversationManager cleanUnreadMessageCountForUser:self.targetUserID];
		}
	}
}

- (void) updateTitle
{
	if (nil != self.targetUserID)
	{
		NSDictionary *targetUserProfile = [ProfileMananger getObjectWithStringID:self.targetUserID];
		
		if (nil != targetUserProfile)
		{
			NSString *title = [[NSString alloc] initWithFormat:@"与%@的对话", [targetUserProfile valueForKey:@"nick"]];
			self.title = title;
			
			[title release];
		}
		else
		{
			[ProfileMananger requestObjectWithStringID:self.targetUserID andHandler:@selector(updateTitle) andTarget:self];
		}
	}
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
	[ConversationManager senMessage:inputer.text.text 
				 toUser:self.targetUserID 
			    withHandler:@selector(newMessageHandler:) 
			      andTarget:self];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - class interface

- (BOOL) newPushMessageForUser:(NSString *)userID
{	
	if ([self.targetUserID isEqualToString:userID] && self.appear)
	{
		[self updateNewerConversation];
		
		return YES;
	}
	
	return NO;
}

+ (BOOL) newPushMessageForUser:(NSString *)userID
{
	return [[self getInstnace] newPushMessageForUser:userID];
}

@end
