//
//  PlaceDetailPage.h
//  Prototype
//
//  Created by Adrian Lee on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceDetailDelegate 

- (void) placeDetailPagePullDown;

@end

@interface PlaceDetailPage : UIViewController
@property (assign) id<PlaceDetailDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *foodDetailView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *score;
@property (retain, nonatomic) IBOutlet UILabel *tag3;
@property (retain, nonatomic) IBOutlet UILabel *tag3Text;
@property (retain, nonatomic) IBOutlet UILabel *tag2;
@property (retain, nonatomic) IBOutlet UILabel *tag2Text;
@property (retain, nonatomic) IBOutlet UILabel *tag1;
@property (retain, nonatomic) IBOutlet UILabel *tag1Text;
@property (strong, nonatomic) NSDictionary *placeObject;
@property (retain, nonatomic) IBOutlet UIView *titleView;

@end
