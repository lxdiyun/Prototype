//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface LoginManager : ObjectManager
+ (void) request;
+ (void) requestWithHandler:(SEL)handler andTarget:(id)target;
+ (void) handleNotLoginMessage:(id)messsge;
+ (void) changeLoginUser;
+ (void) logoutCurrentUser;
@end
