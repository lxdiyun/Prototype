//
//  PlaceDetailPage.h
//  Prototype
//
//  Created by Adrian Lee on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@interface FoodDetailController : UITableViewController

@property (strong, nonatomic) NSDictionary *foodObject;
@property (assign, nonatomic) id<SwipeDelegate> delegate;

@end
