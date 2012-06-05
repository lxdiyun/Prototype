//
//  SinaweiboOAuthv1LoginVC.m
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinaweiboOAuthv1LoginVC.h"

#import <ytoolkit/ymacros.h>
#import <ytoolkit/ycocoaadditions.h>
#import <ytoolkit/yoauthadditions.h>

#import "Util.h"
#import "LoginManager.h"

NSString * const kSinaweiboApiKey = @"925034988";
NSString * const kSinaweiboApiSecret = @"d55d901c182f7df38d6ccabc29684314";
NSString * const kSinaweiboApiCallbackURL = @"http://www.meishiwanjia.com";

@interface SinaweiboOAuthv1LoginVC () <UIAlertViewDelegate>

@property (strong) UIAlertView *newlyLoginAlert;

@end

@implementation SinaweiboOAuthv1LoginVC

@synthesize webView;
@synthesize activityIndicator;
@synthesize newlyLoginAlert = _newlyLoginAlert;

#pragma mark - View lifecycle

- (void) back
{
	POP_VC(self.navigationController, YES);
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.title = @"美食玩家";
	self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void) viewDidUnload
{
	[self setWebView:nil];
	[self setActivityIndicator:nil];
	self.newlyLoginAlert = nil;
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	[webView release];
	[activityIndicator release];
	self.newlyLoginAlert = nil;
	[super dealloc];
}


#pragma mark - Network
- (void) requestFinished:(ASIHTTPRequest *)request 
{
	LOG(@"response:%@", request.responseString);
	NSDictionary * params = [request.responseString decodedUrlencodedParameters];
	self.accesstoken = [params objectForKey:YOAuthv1OAuthTokenKey];
	self.tokensecret = [params objectForKey:YOAuthv1OAuthTokenSecretKey];
	self.userid = [params objectForKey:SINA_OAUTH_V1_TOKEN_USERID];
	NSString * confirmed = [params objectForKey:YOAuthv1OAuthCallbackConfirmedKey];

	if(confirmed)NSLog(@"callback is confirmed:%@", confirmed);

	if (self.accesstoken && self.tokensecret) 
	{
		if (0 == _step) 
		{
			NSString * url = [NSString stringWithFormat:@"http://api.t.sina.com.cn/oauth/authorize?%@=%@&oauth_callback=%@",
					  YOAuthv1OAuthTokenKey, 
					  self.accesstoken, 
					  kSinaweiboApiCallbackURL];
			NSMutableURLRequest * r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
			[self.webView loadRequest:r];
			[self.activityIndicator startAnimating];
		}
		else 
		{
			self.navigationItem.leftBarButtonItem.enabled = NO;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:LOGIN_SINA] forKey:LOGIN_TYPE_KEY];
			[self.delegate oauthv1LoginDidFinishLogging:self];
		}
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request 
{
	UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:[[self class] description]
							      message:[request.error localizedDescription]
							     delegate:nil
						    cancelButtonTitle:@"OK"
						    otherButtonTitles:nil] autorelease];
	[alertView show];

	LOG(@"response:%@", request.responseString);
	NSDictionary * params = [request.responseString decodedUrlencodedParameters];
	id cn = [params objectForKey:@"error_CN"];
	if (nil != cn)
	{
		LOG(@"cn:%@", cn);
	}
}

#pragma mark - UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView 
{
	[self.activityIndicator stopAnimating];
}

- (BOOL) webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType 
{
	NSURL * url = request.URL;
	NSString * s = [url absoluteString];
	NSString * host = [s host];
	LOG(@"load Request to: %@", s);

	if ([host isEqualToString:[kSinaweiboApiCallbackURL host]]) 
	{
		NSDictionary * p = [s queryParameters];
		NSString * verifier = [p objectForKey:YOAuthv1OAuthVerifierKey];
		NSString * token = [p objectForKey:YOAuthv1OAuthTokenKey];
		ASIHTTPRequest * r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/access_token"]];
		[r setRequestMethod:@"POST"];
		r.delegate = self;
		[r prepareOAuthv1AuthorizationHeaderUsingConsumerKey:kSinaweiboApiKey
						   consumerSecretKey:kSinaweiboApiSecret
							       token:token
							 tokenSecret:self.tokensecret
						     signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
							       realm:nil
							    verifier:verifier
							    callback:nil];
		_step = 1;
		[self.activityIndicator startAnimating];
		[r startAsynchronous];

		return NO;
	}
	
	return YES;
}

#pragma mark - interface

- (void) startLogin
{		
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/request_token"]];
	request.delegate = self;
	[request setRequestMethod:@"POST"];
	[request prepareOAuthv1AuthorizationHeaderUsingConsumerKey:kSinaweiboApiKey
						 consumerSecretKey:kSinaweiboApiSecret
							     token:nil
						       tokenSecret:nil
						   signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
							     realm:nil
							  verifier:nil
							  callback:kSinaweiboApiCallbackURL];
	_step = 0;
	self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.activityIndicator startAnimating];
	
	LOG(@"%@", [request.requestHeaders valueForKey:@"Authorization"]);
	[request startAsynchronous];
}

- (void) newUserLogin
{
	if (nil == self.newlyLoginAlert)
	{
		@autoreleasepool 
		{
			UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
			alert.title = @"欢迎加入美食玩家";
			alert.message = @"顺便关注美食玩家的微博吗？";
			[alert addButtonWithTitle:@"Cancel"];
			[alert addButtonWithTitle:@"OK"];
			alert.cancelButtonIndex = 0;
			alert.delegate = self;
			self.newlyLoginAlert = alert;
		}
	}
	
	[self.newlyLoginAlert show];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (1 == buttonIndex)
	{
		NSString *url = [NSString stringWithFormat:@"http://api.t.sina.com.cn/friendships/create/2546303614.json?source=%@", kSinaweiboApiKey];
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
		request.delegate = self;
		[request setRequestMethod:@"POST"];

		[request startSynchronous];
	}
}

@end
