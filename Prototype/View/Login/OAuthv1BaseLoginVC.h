//
//  OAuthv1BaseLoginVC.h
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OAuthv1BaseLoginVC;
@protocol OAuthv1LoginDelegate <NSObject>

- (void)oauthv1LoginDidFinishLogging:(OAuthv1BaseLoginVC *)loginViewController;

@end

@interface OAuthv1BaseLoginVC : UIViewController
@property (nonatomic, copy) NSString * accesstoken;
@property (nonatomic, copy) NSString * tokensecret;
@property (nonatomic, copy) NSString * userid;
@property (nonatomic, assign) id<OAuthv1LoginDelegate> delegate;
- (void) cleanLoginInfo;
@end
