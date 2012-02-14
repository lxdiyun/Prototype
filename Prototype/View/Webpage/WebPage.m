//
//  WebPage.m
//  Prototype
//
//  Created by Adrian Lee on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"

@interface WebPage () <UIWebViewDelegate>
{
	UIWebView *_webView;
}
@property (strong) UIWebView *webView;

@end

@implementation WebPage

@synthesize webView = _webView;

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
		self.webView = [[[UIWebView alloc] init] autorelease];
		
		self.webView.delegate = self;
		
		self.view = self.webView;
		
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com/"]]];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
