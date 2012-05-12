//
//  AvatarV.h
//  Prototype
//
//  Created by Adrian Lee on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageV.h"
#import "Util.h"

@interface AvatarV : UIView

- (IBAction)tap:(id)sender;

@property (strong, nonatomic) NSDictionary *user;
@property (assign, nonatomic) id<ShowVCDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIButton *button;
@property (retain, nonatomic) IBOutlet ImageV *avator;


@end
