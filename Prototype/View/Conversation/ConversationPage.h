//
//  ConversationList.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationPage : UITableViewController

+ (void) updateBage:(NSInteger)unreadMessageCount;
+ (void) updateConversationList;

@end
