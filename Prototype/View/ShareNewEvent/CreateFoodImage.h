//
//  CreateFoodHeader.h
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageV.h"

@interface CreateFoodImage : UIView

@property (strong, nonatomic) ImageV *selectedImage;
@property (strong) NSString *uploadFileID;
@property (strong, nonatomic) UIProgressView *progressView;

- (void) redrawAll;
- (void) cleanImage;
- (void) resetProgress;
@end
