//
//  BackgroundManager.h
//  Prototype
//
//  Created by Adrian Lee on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectManager.h"

@interface BackgroundManager : ObjectManager

+ (void) refreshWith:(SEL)handler and:(id)target;
+ (BOOL) isRefreshing;
+ (NSDate *) lastRefreshDate;
+ (NSInteger) count;
+ (NSNumber *) backgroundFor:(NSInteger)index;
+ (void) setBackground:(NSNumber *)imageID with:(SEL)handler and:(id)target;

@end
