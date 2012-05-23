//
//  MessageCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@interface MessageCell : UITableViewCell <CustomXIBObject>

@property (strong,nonatomic) NSDictionary *conversationListDict;
@property (retain, nonatomic) IBOutlet UILabel *message;
@property (retain, nonatomic) IBOutlet UILabel *name;

@end
