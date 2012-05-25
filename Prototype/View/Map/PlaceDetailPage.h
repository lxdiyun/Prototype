//
//  PlaceDetailPage.h
//  Prototype
//
//  Created by Adrian Lee on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapFoodPage.h"
#import "MapFoodHeader.h"

@protocol PlaceDetailDelegate 

- (void) placeDetailPagePullDown;

@end

@interface PlaceDetailPage : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) NSDictionary *placeObject;
@property (assign) id<PlaceDetailDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *foodsView;
@property (retain, nonatomic) IBOutlet MapFoodHeader *foodTitle;

@end
