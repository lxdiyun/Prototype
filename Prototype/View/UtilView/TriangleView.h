//
//  TriangleView.h
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriangleView : UIView
{
	UIColor *_color;
}

@property (strong) UIColor *color;

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color;
@end
