//
//  MapViewPage.h
//  Prototype
//
//  Created by Adrian Lee on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewPage : UIViewController

- (void) showAllPlaces;

@property (strong, nonatomic) NSDictionary *mapObject;
@property (assign, nonatomic) BOOL saveWhenLeaved;

@end
