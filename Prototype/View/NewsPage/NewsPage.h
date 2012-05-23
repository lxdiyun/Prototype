//
//  NewsPage.h
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListPage.h"

@interface NewsPage : ListPage

+ (void) setUnreadMessageCount:(NSInteger)count;
+ (void) setUnNoticeCount:(NSInteger)count;
+ (void) updateMessage;

@end
