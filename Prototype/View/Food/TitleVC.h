//
//  titleVC.h
//  Prototype
//
//  Created by Adrian Lee on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleVC : UIViewController

- (void) updateGUI;

@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *placeName;
@property (retain, nonatomic) NSDictionary *object;

@end
