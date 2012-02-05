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

const static uint32_t CONVERSATION_DETAIL_REFRESH_WINDOW = 21;

@interface  ConversationDetailPage  ()  <TextInputerDeletgate>
{
	NSString *_targetUserID;
	TextInputer *_inputer;
	UINavigationController *_navco;
}
@property (strong) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@end

@implementation ConversationDetailPage

@synthesize targetUserID = _targetUserID;
@synthesize inputer = _inputer;
@synthesize navco = _navco;

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
	{
		// Custom initialization
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

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (nil != self.targetUserID)
	{
		[ConversationManager requestNewerWithListID:self.targetUserID 
						   andCount:CONVERSATION_DETAIL_REFRESH_WINDOW 
						withHandler:@selector(reloadData) 
						  andTarget:self.tableView];
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
	// Return the number of sections.
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
	
	NSString *conversationID = [[ConversationManager keyArrayForList:self.targetUserID] objectAtIndex:indexPath.row];
	
	NSDictionary *messageDict = [ConversationManager getObject:conversationID inList:self.targetUserID];
	
	cell.conversationDict = messageDict;
	
	return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *conversationID = [[ConversationManager keyArrayForList:self.targetUserID] objectAtIndex:indexPath.row];
	
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

- (void)newMessageHandler:(id)result
{
	[ConversationManager requestNewerWithListID:self.targetUserID 
					   andCount:CONVERSATION_DETAIL_REFRESH_WINDOW 
					withHandler:@selector(reloadData) 
					  andTarget:self.tableView];
	[self.tableView reloadData];
	
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
	[ConversationManager createConversation:inputer.text.text 
					forList:self.targetUserID 
				    withHandler:@selector(newMessageHandler:) 
				      andTarget:self];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
