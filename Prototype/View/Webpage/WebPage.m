//
//  WebPage.m
//  Prototype
//
//  Created by Adrian Lee on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"

#import "Util.h"

@interface WebPage () <UIWebViewDelegate>
{
	UIWebView *_webView;
	UIBarButtonItem *_goBackButton;
}

@property (strong) UIWebView *webView;
@property (strong) UIBarButtonItem *goBackButton;

@end

@implementation WebPage

@synthesize webView = _webView;
@synthesize goBackButton = _goBackButton;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		// Custom initialization
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

- (void) loadView
{
	@autoreleasepool
	{
		
		self.goBackButton = [[[UIBarButtonItem alloc] initWithTitle:@"返回" 
								      style:UIBarButtonItemStylePlain 
								     target:self 
								     action:@selector(goBack)] 
				     autorelease];
		
		self.webView = [[[UIWebView alloc] init] autorelease];
		self.webView.scalesPageToFit = YES;
		self.webView.delegate = self;
		
		self.view = self.webView;
		
		// TODO replace with right web address
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://alpha.meishiwanjia.com:8080"]]];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.webView = nil;
	self.goBackButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType
{
	LOG(@"request = %@", request);

	return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	if ([self.webView canGoBack])
	{
		self.navigationItem.rightBarButtonItem = self.goBackButton;
	}
	else
	{
		self.navigationItem.rightBarButtonItem = nil;
	}
}

#pragma mark - action and interface

- (void) goBack
{
	if ([self.webView canGoBack])
	{
		[self.webView goBack];
	}
}

@end
