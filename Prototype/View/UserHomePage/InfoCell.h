//
//  InfoCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"
#import "ShadowV.h"
#import "Util.h"

@interface InfoCell : UITableViewCell <CustomXIBObject>

- (void) initGUI;
- (void) updateGUI;

- (IBAction) showFollow:(id)sender;
- (IBAction) showFans:(id)sender;

@property (retain, nonatomic) IBOutlet ImageV *avatar;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *place;
@property (retain, nonatomic) IBOutlet UILabel *intro;
@property (retain, nonatomic) IBOutlet UIButton *follow;
@property (retain, nonatomic) IBOutlet UIButton *fans;
@property (retain, nonatomic) IBOutlet UIImageView *background;
@property (retain, nonatomic) IBOutlet ShadowV *shadow;

@property (assign, nonatomic) id<ShowVCDelegate> delegate;
@property (retain, nonatomic) NSDictionary *user;

@end
