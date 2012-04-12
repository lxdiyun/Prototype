//
//  ConversationDetail.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationDetail.h"

#import "ConversationManager.h"

@interface  ConversationDetail  ()  
{
	NSString *_targetUserID;
}
@end

@implementation ConversationDetail

@synthesize targetUserID = _targetUserID;

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
	
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	self.targetUserID = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (nil != self.targetUserID)
	{
		[ConversationManager requestNewerWithListID:self.targetUserID andCount:20 withHandler:@selector(reloadData) andTarget:self.tableView];
	}
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
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSString *conversationID = [[ConversationManager keyArrayForList:self.targetUserID] objectAtIndex:indexPath.row];
	
	NSDictionary *messageDict = [ConversationManager getObject:conversationID inList:self.targetUserID];
	
	if (nil != messageDict)
	{
		cell.textLabel.text = [messageDict valueForKey:@"msg"];
		cell.detailTextLabel.text = [messageDict valueForKey:@"created_on"];
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

@end
