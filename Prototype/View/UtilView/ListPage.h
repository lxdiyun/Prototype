//
//  UserListPage.h
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PullToRefreshV.h"

const static NSUInteger REFRESH_WINDOW = 21;
const static NSUInteger ROW_TO_MORE_FROM_BOTTOM = 5;

@interface ListPage : UITableViewController

// method that must be overwrite by sub classes
// table view
- (NSInteger) tableView:(UITableView *)tableView 
  numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *) tableView:(UITableView *)tableView 
	  cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat) tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
// object manange
- (void) pullToRefreshRequest;
- (void) viewWillAppearRequest;
- (void) requestOlder;
- (BOOL) isUpdating;
- (NSDate* ) lastUpdateDate;

// method that may be overwrite by sub classes
// life circle
- (id) init;
- (void) dealloc;
- (void) didReceiveMemoryWarning;
// view life circle
- (void) viewDidLoad;
- (void) viewWillAppear:(BOOL)animated;
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
// table view
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath;
// GUI
- (void) back;
- (void) reload;
- (void) initGUI;

@property (assign, nonatomic) NSInteger lastRowCount;
@property (strong, nonatomic) PullToRefreshV *refreshHeader;
@property (assign, nonatomic) PULL_TO_REFRESH_STYLE refreshStyle;

@end
