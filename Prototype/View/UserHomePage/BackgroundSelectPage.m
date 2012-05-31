//
//  BackgroundSelectPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BackgroundSelectPage.h"

#import "BackgroundManager.h"
#import "BackgroundListCell.h"

@interface BackgroundSelectPage ()
{
	NSNumber *_selectedImageID;
	UIImageView *_checkMark;
}

@property (strong, nonatomic) NSNumber *selectedImageID;
@property (strong, nonatomic) UIImageView *checkMark;

@end

@implementation BackgroundSelectPage

@synthesize selectedImageID = _selectedImageID;
@synthesize checkMark = _checkMark;

#pragma mark - life cirlce

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			self.checkMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected.png"]] autorelease];
		}
	}
	
	return self;
}


- (void) dealloc
{
	self.selectedImageID = nil;
	self.checkMark = nil;
	
	[super dealloc];
}

#pragma mark - table view data source

- (NSInteger) tableView:(UITableView *)tableView 
  numberOfRowsInSection:(NSInteger)section
{
	return [BackgroundManager count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView 
cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"BackgroundListCell";
	
	BackgroundListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [BackgroundListCell createFromXIB];
	}
	
	NSNumber *imageID =  [BackgroundManager backgroundFor:indexPath.row];
	
	cell.image.picID = imageID;
	
	if (CHECK_EQUAL(self.selectedImageID, imageID))
	{
		cell.accessoryView = self.checkMark;
	}
	else 
	{
		cell.accessoryView = nil;
	}
	
	
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return BACKGROUND_LIST_CELL_HEIGTH;
}

#pragma mark - table view delegate

- (void) tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedImageID = [BackgroundManager backgroundFor:indexPath.row];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	[self.tableView reloadData];
}

#pragma mark - object manage

- (void) pullToRefreshRequest
{
	[BackgroundManager refreshWith:@selector(reload) and:self];
	
	self.lastRowCount = 0;
	[self.tableView reloadData];
	
	self.selectedImageID = nil;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
}

- (void) viewWillAppearRequest
{
	[self pullToRefreshRequest];
}

- (void) requestOlder
{
	// do nothind
}

- (BOOL) isUpdating
{
	return [BackgroundManager isRefreshing];
}

- (NSDate* ) lastUpdateDate
{
	return [BackgroundManager lastRefreshDate];
}

- (void) changeBackground
{
	if (nil != self.selectedImageID)
	{
		[BackgroundManager setBackground:self.selectedImageID with:@selector(back) and:self];
	}
}

#pragma mark - GUI

- (void) initGUI
{
	[super initGUI];
	
	self.navigationItem.rightBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"完成", self, @selector(changeBackground));
	self.title = @"选择背景";
}

@end
