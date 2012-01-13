//
//  FoutCountView.h
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FourCountView : UIView
+ (CGFloat) calculateWidthForFood:(NSDictionary *)foodDict;
- (id) initWithFrame:(CGRect)frame andFoodDict:(NSDictionary *)foodDict;
@end
