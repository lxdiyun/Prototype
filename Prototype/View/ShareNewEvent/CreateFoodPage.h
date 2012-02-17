//
//  NewFoodView.h
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreateFoodPage : UITableViewController 
- (void) imageUploadCompleted:(id)result;
- (void) needScrollToBegin;
- (void) resetImageWithUploadFileID:(NSInteger)fileID;
@end
