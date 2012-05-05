//
//  TriangleCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriangleCell : UITableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style 
     reuseIdentifier:(NSString *)reuseIdentifier
	   backColor:(UIColor *)backColor
       triangleColor:(UIColor *)triangleColor;

@end
