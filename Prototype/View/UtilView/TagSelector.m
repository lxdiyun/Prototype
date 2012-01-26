//
//  TagSelector.m
//  Prototype
//
//  Created by Adrian Lee on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagSelector.h"

#import "Util.h"

const static uint8_t DEFAULT_TAGS_COUNT = 12;
const static NSString *DEFUALT_TAGS[DEFAULT_TAGS_COUNT] = 
{
	@"家常私房", 
	@"糖水甜品", 
	@"特产手信", 
	@"特色小吃", 
	@"蔬果主义", 
	@"无肉不欢", 
	@"水产海鲜", 
	@"啡茶糕品", 
	@"把酒言欢", 
	@"异国风味", 
	@"山珍海味", 
	@"旅行便当"
};

@interface TagSelector ()
{
	NSMutableArray *_tags;
	NSMutableDictionary *_selectedFlags;
	NSString *_selctedTags;
	id<TagSelectorDelegate> _delegate;
}
@property (strong, nonatomic) NSMutableDictionary *selectedFlags;

- (void) reset;

@end

@implementation TagSelector

@synthesize tags = _tags;
@synthesize selctedTags = _selctedTags;
@synthesize delegate = _delegate;
@synthesize selectedFlags = _selectedFlags;

#pragma mark - life circle

- (void) setupDefaultTags
{
	NSMutableArray *tagArray = [[NSMutableArray alloc] init];

	for (int i = 0; i < DEFAULT_TAGS_COUNT; ++i) 
	{
		[tagArray addObject:DEFUALT_TAGS[i]];
	}

	self.tags = tagArray;

	[tagArray release];  
}

- (void) setupButton
{
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
						   initWithTitle:@"完成"
						   style:UIBarButtonItemStyleDone 
						   target:self 
						   action:@selector(didSelectTags:)] autorelease];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
						  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
						  target:self 
						  action:@selector(cancelSelectTags:)] autorelease];
}

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];

	if (nil != self) 
	{
		@autoreleasepool 
		{
			[self setupButton];

			[self setupDefaultTags];
			
			self.title = @"美食类型";
			
			self.tableView.backgroundColor = [Color grey1Color];
		}
	}

	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[super viewDidUnload];

	self.tags = nil;
	self.selctedTags = nil;
	self.selectedFlags = nil;
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
	return self.tags.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	NSString *tagString = [self.tags objectAtIndex:indexPath.row];
	
	cell.textLabel.text = tagString;
	
	if (YES == [[self.selectedFlags valueForKey:tagString] boolValue])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}

#pragma mark - Table view delegate

- (BOOL) checkSelected
{
	@autoreleasepool 
	{
		for (NSNumber *value in self.selectedFlags.allValues)
		{
			if (YES == [value boolValue])
			{
				return YES;
			}
		}
	}
	
	return NO;
}

- (void) updateDoneButton
{
	if (YES == [self checkSelected])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.leftBarButtonItem.enabled = NO;
	}
}
 

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool 
	{
		NSString *tagString = [self.tags objectAtIndex:indexPath.row];
		
		if (YES == [[self.selectedFlags valueForKey:tagString] boolValue])
		{
			[self.selectedFlags setValue:[NSNumber numberWithBool:NO] forKey:tagString];
		}
		else
		{
			[self.selectedFlags setValue:[NSNumber numberWithBool:YES] forKey:tagString];
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
				 withRowAnimation:UITableViewRowAnimationFade];
		
		[self updateDoneButton];

	}
}

#pragma mark - interface and action

- (void) didSelectTags:(id)sender
{
	@autoreleasepool 
	{
		NSMutableString *selectedTags = [[[NSMutableString alloc] init] autorelease];

		for (NSString *key in self.selectedFlags.allKeys)
		{
			NSNumber *value = [self.selectedFlags valueForKey:key];

			if (YES == [value boolValue])
			{
				[selectedTags appendFormat:@"%@ ", key];
			}
		}

		self.selctedTags = selectedTags;
		
		[self reset];

		[self.tableView reloadData];

		[self.delegate didSelectTags:self];
	}
}

- (void) cancelSelectTags:(id)sender
{
	[self.delegate cancelSelectTags:self];
}


- (void) reset
{
	@autoreleasepool 
	{
		self.selectedFlags = [[[NSMutableDictionary alloc] init] autorelease];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	
}

- (void) setTags:(NSMutableArray *)tags
{
	if (_tags == tags)
	{
		return;
	}
	
	[_tags release];
	
	_tags = [tags retain];
	
	[self reset];
}

@end
