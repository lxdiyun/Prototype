//
//  NoticeHeader.h
//  Prototype
//
//  Created by Adrian Lee on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoldHeader.h"

@interface NoticeHeader : FoldHeader

@property (retain, nonatomic) IBOutlet UILabel *unread;
@property (retain, nonatomic) IBOutlet UILabel *empty;

@end
