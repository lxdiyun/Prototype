//
//  UserFoodHistoryMananger.h
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserQueryFoodManager.h"

@interface UserFoodHistoryManager : UserQueryFoodManager

+ (void) deleteHistoryByFood:(NSNumber *)foodID forUser:(NSNumber *)userID;

@end
