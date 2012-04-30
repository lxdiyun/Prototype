//
//  DoubanOAuthv1LoginVC.h
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OAuthv1BaseLoginVC.h"

@interface DoubanOAuthv1LoginVC : OAuthv1BaseLoginVC <NSURLConnectionDataDelegate, UIWebViewDelegate>
{
    NSMutableData * _networkData;
    
    NSUInteger _step;
}


@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (void) startLogin;

@end
