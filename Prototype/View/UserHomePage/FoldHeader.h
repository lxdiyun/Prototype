//
//  FoldHeader.h
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@protocol FoldDelegate <NSObject>

- (void) fold:(id)sender;

@end

@interface FoldHeader : UIView <CustomXIBObject>

- (void) initGUI;
- (void) resetGUI;

- (IBAction) tap:(id)sender;

@property (assign, nonatomic) BOOL isFolding;
@property (assign, nonatomic) id<FoldDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *foldButton;


@end
