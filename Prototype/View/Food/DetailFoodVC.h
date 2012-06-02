//
//  DetailFoodVC.h
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPage.h"

#import "Util.h"
#import "FoodToolBar.h"
#import "FoodPage.h"

@interface DetailFoodVC : ListPage

- (void) requestNewestComment;
- (void) reloadCommentSection;

@property (strong, nonatomic) NSNumber *foodID;
@property (assign, nonatomic) FoodPage<ShowVCDelegate> *delegate;

@end
