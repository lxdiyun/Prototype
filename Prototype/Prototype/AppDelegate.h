//
//  AppDelegate.h
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (UIViewController *) currentViewController;
@end
