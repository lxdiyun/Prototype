//
//  Event.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventPage.h"

#import "Util.h"
#import "FoodPage.h"
#import "EventCell.h"

@interface EventPage ()
{
	NSMutableDictionary *_eventDict;
	NSArray *_eventArray;
	NSMutableDictionary *_imageDict;
	
	FoodPage *_foodPage;
}

@property (retain) NSMutableDictionary *eventDict;
@property (retain) NSMutableDictionary *imageDict;
@property (retain) NSArray *eventArray;
@property (retain) FoodPage *foodPage;

// event message
- (void)updateEvent;
- (void)messageHandler:(id)dict;

// util
- (void)refreshTableView;
@end

static NSInteger eventSort(id event1, id event2, void *context)
{
	NSNumber *v1 = [event1 valueForKey:@"id"];
	NSNumber *v2 = [event2 valueForKey:@"id"];
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}


@implementation EventPage

@synthesize eventDict = _eventDict;
@synthesize imageDict = _imageDict;
@synthesize foodPage = _foodPage;
@synthesize eventArray = _eventArray;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
	{
		// Custom initialization
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
	
	[self setTitle:@"新鲜事"];
	
	// init data
	NSMutableDictionary *tempDict = nil;
	tempDict = [[NSMutableDictionary alloc] init];
	self.eventDict = tempDict;
	[tempDict release];
	
	tempDict = [[NSMutableDictionary alloc] init];
	self.imageDict = tempDict;
	[tempDict release];
	
	// triger message
	[self updateEvent];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	
	// release data 
	self.eventDict = nil;
	self.imageDict = nil;
	self.foodPage = nil;
	self.eventArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{	

	
	[super viewWillAppear:animated];
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
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return self.eventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 160);
		[cell redraw];
	}
	
	// Configure the cell...
	NSDictionary *event = [self.eventArray objectAtIndex:indexPath.row];
	cell.eventDict = event;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *event = [self.eventArray objectAtIndex:indexPath.row];
	
	if (nil == self.foodPage)
	{
		FoodPage *foodPage = [[FoodPage alloc] init];
		self.foodPage = foodPage;
		
		[foodPage release];
	}
	
	self.foodPage.foodDict = event;
	
	[self.navigationController pushViewController:self.foodPage animated:YES];
}

#pragma mark - message
- (void)updateEvent
{
	@autoreleasepool 
	{

		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		
		// TODO update to real username
		[params setValue:[NSNumber numberWithInteger:-1] forKey:@"cursor"];
		[params setValue:[NSNumber numberWithInteger:10] forKey:@"count"];
		
		[request setValue:@"event.get" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(messageHandler:));
	}
}

- (void)messageHandler:(id)dict
{
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}

	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	
	// TODO: remove log
	// LOG(@"Get Message = %@", messageDict);
	
	for (NSDictionary *event in [messageDict objectForKey:@"result"]) 
	{
		[self.eventDict setValue:event forKey:[event objectForKey:@"id"]];
	}
	
	NSArray *unsortedArray = [self.eventDict allValues];
	
	self.eventArray = [unsortedArray sortedArrayUsingFunction:eventSort context:NULL];
	
	[messageDict release];
	
	[self refreshTableView];
}

#pragma mark - util

- (void)refreshTableView
{
	if ([self.view respondsToSelector:@selector(reloadData)])
	{
		// TODO remove log
		// LOG(@"request update view");
		[self.view performSelector:@selector(reloadData)];
	}
}

@end
