//
//  LoginPage.h
//  Prototype
//
//  Created by Adrian Lee on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginPage : UITableViewController
@property (strong) NSString *errorMessage;
- (void) reloadData;
@end
