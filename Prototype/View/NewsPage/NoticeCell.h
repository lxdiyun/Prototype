//
//  NoticeCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"
#import "ImageV.h"

@interface NoticeCell : UITableViewCell <CustomXIBObject>

@property (retain, nonatomic) IBOutlet ImageV *image;
@property (retain, nonatomic) IBOutlet UILabel *message;
@property (retain, nonatomic) IBOutlet ImageV *accessory;

@property (strong, nonatomic) NSDictionary *noticeObject;

@end
