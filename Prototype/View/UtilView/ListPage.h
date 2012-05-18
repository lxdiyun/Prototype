//
//  UserListPage.h
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

const static NSUInteger REFRESH_WINDOW = 21;
const static NSUInteger ROW_TO_MORE_FROM_BOTTOM = 5;

@interface ListPage : UITableViewController

// method that must be overwrite by sub classes
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) requestNewer;
- (void) requestOlder;
- (BOOL) isUpdating;
- (NSDate* ) lastUpdateDate;

// method that may be overwrite by sub classes
- (void) back;
- (void) reload;
- (id) init;

@end
