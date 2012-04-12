//
//  NetworkOperation.h
//  Prototype
//
//  Created by Adrian Lee on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkOperation : NSOperation

- (id) initWithTarget:(id)target action:(SEL)action callbackWhenFinish:(SEL)callBack;

@end
