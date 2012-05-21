//
//  UserFansPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserFansPage.h"

#import "UserHomePage.h"
#import "FansListManager.h"
#import "ProfileMananger.h"
#import "ListCell.h"
#import "AppDelegate.h"

@interface UserFansPage ()
{
	NSString *_userID;
	UserHomePage *_userPage;
}

@property (retain, nonatomic) UserHomePage *userPage;

@end

@implementation UserFansPage

@synthesize userID = _userID;
@synthesize userPage = _userPage;

#pragma mark - life circle

- (void) dealloc
{
	self.userID = nil;
	self.userPage = nil;
	
	[super dealloc];
}

#pragma mark - view life circle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.userPage = [[[UserHomePage alloc] init] autorelease];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self updateUser];
}

#pragma mark - tableview data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[FansListManager keyArrayForList:self.userID] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ListCell";
	ListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [ListCell createFromXIB];
	}
	
	NSString *userID = [[FansListManager keyArrayForList:self.userID] objectAtIndex:indexPath.row];
	
	NSDictionary *user = [ProfileMananger getObjectWithStringID:userID];
	
	if (nil != user)
	{
		cell.name.text = [user valueForKey:@"nick"];
		cell.desc.text = [user valueForKey:@"intro"];
		cell.image.picID = [user valueForKey:@"avatar"];
	}
	else 
	{
		[ProfileMananger requestObjectWithStringID:userID andHandler:@selector(reloadData) andTarget:self.tableView];
	}
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return LIST_CELL_HEIGTH;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *userID = [[FansListManager keyArrayForList:self.userID] objectAtIndex:indexPath.row];
	
	if (nil != userID)
	{
		self.userPage.userID = [NSNumber numberWithInteger:[userID integerValue]];
		
		[self.userPage resetGUI];
		
		[self.navigationController pushViewController:self.userPage animated:YES];

	}
}


#pragma mark - object manage

- (void) pullToRefreshRequest
{
	[FansListManager requestNewestWithListID:self.userID 
				       andCount:REFRESH_WINDOW 
				    withHandler:@selector(reload) 
				      andTarget:self];
}

- (void) requestNewer
{
	[FansListManager requestNewerWithListID:self.userID 
					    andCount:REFRESH_WINDOW 
					 withHandler:@selector(reload) 
					   andTarget:self];
}

- (void) requestOlder
{
	[FansListManager requestOlderWithListID:self.userID 
					    andCount:REFRESH_WINDOW
					 withHandler:@selector(reload) 
					   andTarget:self];
}

- (BOOL) isUpdating
{
	return [FansListManager isUpdatingWithType:REQUEST_NEWEST withListID:self.userID];
}

- (NSDate* ) lastUpdateDate
{
	return [FansListManager lastUpdatedDateForList:self.userID];
}

- (void) updateUser
{
	if (CHECK_EQUAL(self.userID, [GET_USER_ID() stringValue]))
	{
		self.title = @"我的粉丝";
	}
	else 
	{
		NSDictionary *user = [ProfileMananger getObjectWithStringID:self.userID];
		
		if (nil != user)
		{
			NSString *title = [[NSString alloc] initWithFormat:@"%@的粉丝", [user valueForKey:@"nick"]];
			
			self.title = title;
			
			[title release];
		}
		else 
		{
			[ProfileMananger requestObjectWithStringID:self.userID 
							andHandler:@selector(updateUser) 
							 andTarget:self];
		}
	}
	}



@end
