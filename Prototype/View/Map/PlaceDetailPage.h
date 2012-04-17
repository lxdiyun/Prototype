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
@property (strong, nonatomic) NSDictionary *placeObject;
@end
