//
//  DoubanOAuthv1LoginVC.m
//  Prototype
//
//  Created by Adrian Lee on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DoubanOAuthv1LoginVC.h"
#import <ytoolkit/NSMutableURLRequest+YOAuth.h>
#import <ytoolkit/ymacros.h>
#import <ytoolkit/ycocoaadditions.h>
#import <ytoolkit/yoauth.h>

#import "Util.h"
#import "LoginManager.h"

NSString * const kDoubanConsumerKey = @"08732761e528158f19597625af7840ad";
NSString * const kDoubanConsumerSecretKey = @"860543993bab2c66";
NSString * const kDoubanRealm = @"www.douban.com";

@implementation DoubanOAuthv1LoginVC
@synthesize webView;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		_networkData = [[NSMutableData alloc] init];
	}
	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

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
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	[webView release];
	YRELEASE_SAFELY(_networkData);
	[super dealloc];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_networkData setLength:0];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[_networkData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString * s = [[NSString alloc] initWithData:_networkData encoding:NSUTF8StringEncoding];
	if (s) 
	{
		YLOG(@"response:%@",s);
		NSDictionary * p = [s decodedUrlencodedParameters];
		self.accesstoken = [p objectForKey:YOAuthv1OAuthTokenKey];
		self.tokensecret = [p objectForKey:YOAuthv1OAuthTokenSecretKey];
		self.userid = [p objectForKey:DOUBAN_OAUTH_V1_TOKEN_USERID];
		if (self.accesstoken && self.tokensecret) 
		{
			if (0 == _step) 
			{
				NSDictionary * op = [NSDictionary dictionaryWithObjectsAndKeys:self.accesstoken, YOAuthv1OAuthTokenKey, 
						     @"http://ytoolkitdemo/", YOAuthv1OAuthCallbackKey, nil];
				NSString * url = [@"http://www.douban.com/service/auth/authorize" URLStringByAddingParameters:op];
				NSURLRequest * r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
				[self.webView loadRequest:r];
			}
			else 
			{
				self.navigationItem.leftBarButtonItem.enabled = NO;
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:LOGIN_DOUBAN] forKey:LOGIN_TYPE_KEY];
				[self.delegate oauthv1LoginDidFinishLogging:self];
			}
		}
	}
	[s release];
}

- (BOOL) webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType 
{
	NSURL * url = request.URL;
	NSString * s = [url absoluteString];
	NSString * host = [s host];
	if ([host isEqualToString:@"ytoolkitdemo"]) 
	{
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/service/auth/access_token"]];
		[request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
					     consumerSecretKey:kDoubanConsumerSecretKey 
							 token:self.accesstoken
						   tokenSecret:self.tokensecret 
							 realm:kDoubanRealm];
		[_networkData setLength:0];
		_step = 1;
		[NSURLConnection connectionWithRequest:request delegate:self];
		return NO;
	}
	return YES;
}

#pragma mark - interface
- (void) startLogin
{
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/service/auth/request_token"]];
	
	// "old version of oauth.py (Douban is using) requires an 'OAuth realm=' format pattern
	// So, the realm should be specified (even @"")
	[request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
				     consumerSecretKey:kDoubanConsumerSecretKey
						 token:nil
					   tokenSecret:nil
						 realm:kDoubanRealm
					      verifier:nil
					      callback:nil];
	[NSURLConnection connectionWithRequest:request delegate:self];
	_step = 0;
}

@end
