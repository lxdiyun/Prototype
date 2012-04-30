//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

// Login constant varibale
extern NSString * const LOGIN_TYPE_KEY;

// oauth version 1
extern NSString * const SINA_OAUTH_V1_TOKEN_USERID;
extern NSString * const DOUBAN_OAUTH_V1_TOKEN_USERID;
extern NSString * const OAUTH_V1_TOKEN_USERID;
extern NSString * const OAUTH_V1_TOKEN_KEY;
extern NSString * const OAUTH_V1_SECRET_KEY;
extern NSString * const OAUTH_V1_USER_ID_KEY;

// native login
extern NSString * const NATIVE_ACCOUNT_KEY;
extern NSString * const NATIVE_PASSWORD_KEY;


typedef enum LOGIN_TYPE_ENUM
{
	LOGIN_NATIVE = 0x0,
	LOGIN_SINA = 0x1,
	LOGIN_DOUBAN = 0x2,
	LOGIN_TYPE_MAX
} LOGIN_TYPE;

@interface LoginManager : ObjectManager
+ (void) request;
+ (void) requestWithHandler:(SEL)handler andTarget:(id)target;
+ (void) handleNotLoginMessage:(id)messsge;
+ (void) changeLoginUser;
+ (void) logoutCurrentUser;
@end
