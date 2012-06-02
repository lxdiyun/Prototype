//
//  PhotoSelectSheet.h
//  Prototype
//
//  Created by Adrian Lee on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"


@protocol PhototSelectorDelegate;

@interface PhotoSelector : UIViewController
@property (strong) UIImage *selectedImage;
@property (strong) UIActionSheet *actionSheet;
@property (assign) NSObject<PhototSelectorDelegate> *delegate;
@end

@protocol PhototSelectorDelegate <ShowModalVCDelegate>
- (void) didSelectPhotoWithSelector:(PhotoSelector *)selector;
@end