//
//  Alert.h
//  Prototype
//
//  Created by Adrian Lee on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@interface Alert : UIView <CustomXIBObject>

- (void) showIn:(UIView *)view;
- (void) dismiss;

@property (strong, nonatomic) NSString *messageText;
@property (retain, nonatomic) IBOutlet UILabel *message;

@end
