//
//  LoginPageVC.h
//  Prototype
//
//  Created by Adrian Lee on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginPageVC : UIViewController

- (void) cleanInfo;
- (void) newUserLogin;
- (void) startLogin;

- (IBAction) nativeLogin:(id)sender;
- (IBAction) sinaLogin:(id)sender;
- (IBAction) doubanLogin:(id)sender;
- (IBAction) registerNewUser:(id)sender;

@end
