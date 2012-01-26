//
//  TagSelector.h
//  Prototype
//
//  Created by Adrian Lee on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagSelectorDelegate;

@interface TagSelector : UITableViewController

@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSString *selctedTags;
@property (assign, nonatomic) id<TagSelectorDelegate> delegate;

@end

@protocol TagSelectorDelegate

- (void) didSelectTags:(TagSelector *)sender;
- (void) cancelSelectTags:(TagSelector *)sender;

@end
