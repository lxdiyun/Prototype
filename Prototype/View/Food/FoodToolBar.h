//
//  FoodToolBar.h
//  Prototype
//
//  Created by Adrian Lee on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@protocol FoodToolBarDelegate <ShowVCDelegate, ShowModalVCDelegate>

- (void) foodDeleted:(id)sender;
- (void) comentCreated:(id)result;

@end

@interface FoodToolBar : UIToolbar <CustomXIBObject>

@property (assign, nonatomic) id<FoodToolBarDelegate> delegate;
@property (retain, nonatomic) NSDictionary *food;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *locationButton;

- (IBAction) showLocation:(id)sender;
- (IBAction) addComent:(id)sender;
- (IBAction) deleteFood:(id)sender;

@end
