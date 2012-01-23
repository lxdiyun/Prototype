//
//  CreateFoodFourCount.h
//  Prototype
//
//  Created by Adrian Lee on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateFoodFourCountDelegate;

@interface CreateFoodFourCount : UIView
{
	id<CreateFoodFourCountDelegate> _delegate;
}

@property (assign) id<CreateFoodFourCountDelegate> delegate;

- (BOOL) isFourCountSelected;
- (void) setFoutCountParams:(NSMutableDictionary *)params;
- (void) cleanFourCount;

@end

@protocol CreateFoodFourCountDelegate

- (void) fourCountSelected;

@end