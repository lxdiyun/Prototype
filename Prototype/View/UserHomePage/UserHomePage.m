//
//  UserHomePage.m
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserHomePage.h"

#import "UserInfoCell.h"
#import "TextInputer.h"
#import "ConversationManager.h"
#import "NewsPage.h"

@interface UserHomePage () <UserInfoCellDelegate, TextInputerDeletgate>
{
	UserInfoCell *_info;
	UINavigationController *_msgNavco;
	TextInputer *_msgInputer;
}

@property (strong, nonatomic) UINavigationController *msgNavco;
@property (strong, nonatomic) TextInputer *msgInputer;
@property (strong, nonatomic) UserInfoCell *info;

@end

@implementation UserHomePage

@synthesize info = _info;
@synthesize msgNavco = _msgNavco;
@synthesize msgInputer = _msgInputer;

#pragma mark - life circle

- (void) dealloc
{
	self.info = nil;
	self.msgNavco = nil;
	self.msgInputer = nil;
	
	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	[super initGUI];
	
	if (nil == self.info)
	{
		self.info = [UserInfoCell createFromXIB];
		self.info.delegate = self;
	}
	
	if (nil == self.msgInputer)
	{
		self.msgInputer = [[[TextInputer alloc] init] autorelease];
		self.msgInputer.title = @"发送私信";
		self.msgInputer.delegate = self;
	}
	if (nil == self.msgNavco)
	{
		self.msgNavco = [[[UINavigationController alloc] initWithRootViewController:self.msgInputer] autorelease];
		CONFIG_NAGIVATION_BAR(self.msgNavco.navigationBar);
	}
}

- (void) updateGUIWith:(NSDictionary *)user
{
	[super updateGUIWith:user];
	
	self.info.user = user;
}

- (InfoCell *) getInfoCell
{
	return self.info;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[ConversationManager senMessage:inputer.text.text 
				 toUser:[self.userID stringValue] 
			    withHandler:nil 
			      andTarget:nil];
	[NewsPage updateMessage];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UserInfoCellDelegate

- (void) startChat
{
	[self presentModalViewController:self.msgNavco animated:YES];
}

@end
