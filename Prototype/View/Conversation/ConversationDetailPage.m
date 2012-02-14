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

const static uint32_t CONVERSATION_DETAIL_REFRESH_WINDOW = 21;
const static uint32_t ROW_TO_MORE_CONVERSATION = 2;

@interface  ConversationDetailPage  ()  <TextInputerDeletgate>
{
	NSString *_targetUserID;
	TextInputer *_inputer;
	UINavigationController *_navco;
	BOOL _canUpdateOlder;
}
@property (strong) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@property (assign) BOOL canUpdateOlder;

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

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	@autoreleasepool 
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
							   initWithImage:[UIImage imageNamed:@"comIcon.png"] 
							   style:UIBarButtonItemStylePlain 
							   target:self 
							   action:@selector(inputMessage:)] autorelease];
	}
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	self.targetUserID = nil;
	self.inputer = nil;
	self.navco = nil;
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
		self.navco.navigationBar.barStyle = UIBarStyleBlack;
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

- (void) updateNewerConversationHandler
{	
	[self refreshTableView];
	
	[self performSelector:@selector(resetCanUpdateOlder) withObject:nil afterDelay:8.0];
}

- (void) updateOlderConversationHandler
{
	static uint32_t lastOldestID = 0;
	uint32_t currentOldestID = [ConversationManager getOldestKeyForList:self.targetUserID];

	if (lastOldestID == currentOldestID)
	{
		self.canUpdateOlder = NO;
	}
	else
	{
		lastOldestID = currentOldestID;
	}
	
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
		
		if ( 0 <= maxCellIndex && [ConversationManager hasNewMessageForUser:self.targetUserID])
		{
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxCellIndex inSection:0] 
					      atScrollPosition:UITableViewScrollPositionBottom 
						      animated:YES];
			
			[ConversationManager setHasNewMessage:NO forUser:self.targetUserID];
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

@end
