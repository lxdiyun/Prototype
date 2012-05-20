//
//  FoodPage.h
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPage.h"

@interface FoodPage : ListPage

- (void) requestNewerComment;

@property (strong,nonatomic) NSDictionary *foodObject;

@end
