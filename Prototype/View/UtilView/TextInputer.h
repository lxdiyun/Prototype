//
//  TextInputer.h
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextInputerDeletgate;

@interface TextInputer : UIViewController
@property (strong) UITextView *text;
@property (assign) id<TextInputerDeletgate> delegate;
@property (strong) NSString *sendButtonTitle;
@property (assign) BOOL drawCancel;
@property (assign, nonatomic) BOOL appearing;
@property (assign, nonatomic) BOOL acceptEmpty;
@end

@protocol TextInputerDeletgate
- (void) textDoneWithTextInputer:(TextInputer *)inputer;
- (void) cancelWithTextInputer:(TextInputer *)inputer;
@end
