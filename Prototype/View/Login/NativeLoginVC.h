//
//  NativeLoginVC.h
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NativeLoginVC : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *account;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UILabel *accountLabel;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;

- (void) cleanLoginInfo;

@end
