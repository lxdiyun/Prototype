//
//  SinaweiboOAuthv1LoginVC.h
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAuthv1BaseLoginVC.h"
#import "ASIHTTPRequest+YOAuthv1Request.h"

@interface SinaweiboOAuthv1LoginVC : OAuthv1BaseLoginVC <ASIHTTPRequestDelegate, UIWebViewDelegate>
{
	NSUInteger _step;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) startLogin;
- (void) newUserLogin;
@end
