//
//  HomePage.h
//  Prototype
//
//  Created by Adrian Lee on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoCell.h"
#import "FoodPage.h"
#import "MapViewPage.h"
#import "ListPage.h"

@interface HomePage : ListPage <ShowVCDelegate>

- (InfoCell *) getInfoCell;
- (void) initGUI;
- (void) restGUI;
- (void) updateGUIWith:(NSDictionary *)user;
- (void) requestUserInfo;

@property (retain, nonatomic) NSNumber *userID;
@property (retain, nonatomic) MapViewPage *mapPage;
@property (retain, nonatomic) FoodPage *foodPage;

@end
