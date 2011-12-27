//
//  Event.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventPage.h"

#import "Util.h"
#import "NetworkService.h"
#import "FoodPage.h"
#import "EventCell.h"

@interface EventPage ()
{
	NSMutableDictionary *_eventDict;
	NSMutableDictionary *_imageDict;
	
	FoodPage *_foodPage;
}

@property (retain) NSMutableDictionary *eventDict;
@property (retain) NSMutableDictionary *imageDict;
@property (retain) FoodPage *foodPage;

// event message
- (void)updateEvent;
- (void)messageHandler:(id)dict;

// util
- (void)performOperation:(SEL)action withObject:(id)object;
- (void)loadImage:(id)dict;
- (void)refreshTableView;
@end

@implementation EventPage

@synthesize eventDict = _eventDict;
@synthesize imageDict = _imageDict;
@synthesize foodPage = _foodPage;

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

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;

	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	
	// release data 
	self.eventDict = nil;
	self.imageDict = nil;
	self.foodPage = nil;
	
}

- (void)viewWillAppear:(BOOL)animated
{	
	// triger message
	[self updateEvent];
	
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
	return self.eventDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 180);
		[cell setup];
	}
	
	// Configure the cell...
	
	// configue text
	NSArray *allEvent = [self.eventDict allValues];
	NSDictionary *event = [allEvent objectAtIndex:indexPath.row];
	cell.eventDict = event;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 180;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
// Return NO if you do not want the specified item to be editable.
return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
if (editingStyle == UITableViewCellEditingStyleDelete) {
// Delete the row from the data source
[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}   
else if (editingStyle == UITableViewCellEditingStyleInsert) {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
// Return NO if you do not want the item to be re-orderable.
return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *allEvent = [self.eventDict allValues];
	NSDictionary *event = [allEvent objectAtIndex:indexPath.row];
	
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
	@autoreleasepool {
		uint32_t messageID = GET_MSG_ID();
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableData *messageData = [[[NSMutableData alloc] init] autorelease];
		
		// TODO update to real username
		[params setValue:[NSNumber numberWithInteger:-1] forKey:@"cursor"];
		[params setValue:[NSNumber numberWithInteger:10] forKey:@"count"];
		
		[request setValue:@"event.get" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		[request setValue:[NSNumber numberWithUnsignedLong:messageID] forKey:@"id"];
		
		CONVERT_MSG_DICTONARY_TO_DATA(request, messageData);
		
		[[NetworkService getInstance] requestsendAndHandleMessage:messageData 
							       withTarget:self 
							      withHandler:@selector(messageHandler:) 
							    withMessageID:messageID];
	}
}

- (void)messageHandler:(id)dict
{
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		NSLog(@"Error handle non dict object");
		return;
	}

	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	
	// TODO: remove log
	// NSLog(@"Get Message = %@", messageDict);
	
	for (NSDictionary *event in [messageDict objectForKey:@"result"]) 
	{
		// TODO: remove log
		// NSLog(@"Event name = %@", [event objectForKey:@"name"]);
		// NSLog(@"Event desc = %@", [event objectForKey:@"desc"]);
		
		NSDictionary *picDict = [event objectForKey:@"pic"];
		
		[self performOperation:@selector(loadImage:) withObject:picDict];
		[self.eventDict setValue:event forKey:[event objectForKey:@"id"]];
	}
	
	[messageDict release];
	
	[self refreshTableView];
}

#pragma mark - util
- (void)performOperation:(SEL)action withObject:(id)object
{
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self 
										selector:action
										  object:object];
	PERFORM_OPERATION(operation);
	[operation release];
}

- (void)loadImage:(id)dict
{
	if (![dict isKindOfClass:[NSDictionary class]])
	{
		return;
	}
	
	@autoreleasepool 
	{
		NSDictionary *picDict = [dict retain];
		NSString *picID = [[dict objectForKey:@"id"] stringValue];
		if (nil == [self.imageDict valueForKey:picID])
		{
			NSString *imageURLString = [picDict objectForKey:@"size200"];
			NSURL *imageUrl = [[NSURL alloc] initWithString:imageURLString];
			NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
			UIImage *image = [UIImage imageWithData:imageData];
			[self.imageDict setValue:image forKey:picID];
			
			[imageUrl release];
		}
		
		[dict release];
		
		[self performSelectorOnMainThread:@selector(refreshTableView)
				       withObject:self
				    waitUntilDone:NO];
	}

}

- (void)refreshTableView
{
	if ([self.view respondsToSelector:@selector(reloadData)])
	{
		// TODO remove log
		// NSLog(@"request update view");
		[self.view performSelector:@selector(reloadData)];
	}
}

@end
