//
//  CommentCell.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailCell.h"

#import "ImageV.h"
#import "Util.h"
#import "ProfileMananger.h"

const static CGFloat AVATOR_SIZE = 30;
const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 13.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 7.0; // padding from top virtical boder
const static CGFloat PADING4 = 0.0; // padding between element virtical and bottom border

@interface DetailCell () 
{
@private
	NSDictionary *_conversationListDict;
	NSDictionary *_userProfileDict;
	UILabel *_userAndDate;
	UILabel *_message;
	ImageV *_avatorImageV;
}

@property (strong, nonatomic) UILabel *userAndDate;
@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) ImageV *avatorImageV;

@end

@implementation DetailCell

@synthesize conversationDict = _conversationListDict;
@synthesize userProfile = _userProfileDict;
@synthesize userAndDate = _userAndDate;
@synthesize message = _message;
@synthesize avatorImageV = avatorImageV;

# pragma mark - class method

+ (CGFloat) getConversationHeightFor:(NSDictionary *)commentDict forCommentWidth:(CGFloat)width
{
	NSString *commentString = [commentDict valueForKey:@"msg"];
	CGFloat commentHeight = FONT_SIZE * PROPORTION();
	
	if ((nil != commentString) && (0 < commentString.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		commentHeight = [commentString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE * PROPORTION()] constrainedToSize:constrained lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	return  commentHeight;
}

+ (CGFloat) cellHeightForConversation:(NSDictionary *)commentDict forCellWidth:(CGFloat)width
{
	width = width - ((PADING1 * 2 + AVATOR_SIZE + PADING2) * PROPORTION());
	CGFloat commentHeight = [self getConversationHeightFor:commentDict forCommentWidth:width];
	return commentHeight + (FONT_SIZE + PADING4 + PADING3 * 2) * PROPORTION();
}

# pragma mark - life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) 
	{
		// Initialization code
	}
	return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void) dealloc
{
	self.conversationDict = nil;
	self.userAndDate = nil;
	self.message = nil;
	self.avatorImageV = nil;
	
	[super dealloc];
}

#pragma mark - draw cell

- (void) redrawImageV
{
	if (nil != self.avatorImageV)
	{
		[self.avatorImageV removeFromSuperview];
	}
	
	self.avatorImageV = [[[ImageV alloc] initWithFrame:CGRectMake(PADING1 * PROPORTION(), 
								      PADING3 * PROPORTION(), 
								      AVATOR_SIZE * PROPORTION(), 
								      AVATOR_SIZE * PROPORTION())] 
			     autorelease];
	
	[self.contentView addSubview:self.avatorImageV];
	
	if (nil != self.userProfile)
	{
		NSNumber *avatarID = [self.userProfile valueForKey:@"avatar"];
		
		self.avatorImageV.picID = avatarID;
		
	}
}

- (void) redrawUserAndDate
{
	if (nil != self.userAndDate)
	{
		[self.userAndDate removeFromSuperview];
	}
	
	UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
	
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = PADING3;
	CGFloat width = self.contentView.frame.size.width - ((X + PADING2) * PROPORTION());
	CGFloat height = FONT_SIZE;
	
	self.userAndDate = [[[UILabel alloc] init] autorelease];
	self.userAndDate.frame = CGRectMake(X * PROPORTION(),
					    Y * PROPORTION(),
					    width,
					    height * PROPORTION());
	
	self.userAndDate.font = font;
	self.userAndDate.adjustsFontSizeToFitWidth = YES;
	self.userAndDate.backgroundColor = [UIColor clearColor];
	
	NSString *nick = @"";
	NSString *createTime  = @"";
	if (nil != self.userProfile)
	{
		nick = [self.userProfile valueForKey:@"nick"];
	}
	
	if (nil != self.conversationDict)
	{
		createTime = [self.conversationDict valueForKey:@"created_on"];
	}
	
	self.userAndDate.text = [NSString stringWithFormat:@"%@  %@", nick, createTime];
	
	[self.contentView addSubview:self.userAndDate];
}

- (void) redrawMessage
{
	if (nil != self.message)
	{
		[self.message removeFromSuperview];
	}
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE * PROPORTION()];
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = PADING3 + FONT_SIZE + PADING4;
	CGFloat width = self.contentView.frame.size.width - ((X + PADING2) * PROPORTION());
	CGFloat height = [[self class] getConversationHeightFor:self.conversationDict 
					   forCommentWidth:width];
	
	self.message = [[[UILabel alloc] 
			 initWithFrame:CGRectMake(X * PROPORTION(),
						  Y * PROPORTION(),
						  width,
						  height)] 
			autorelease];
	
	self.message.numberOfLines = 0;
	self.message.font = font;
	self.message.backgroundColor = [UIColor clearColor];
	self.message.adjustsFontSizeToFitWidth = NO;
	self.message.lineBreakMode = UILineBreakModeWordWrap;
	
	
	
	if (nil != self.conversationDict)
	{
		self.message.text = [self.conversationDict valueForKey:@"msg"];
	}
	
	[self.contentView addSubview:self.message];
}

#pragma mark - message

- (void) requestUserProfile
{
	NSNumber * userID = [self.conversationDict valueForKey:@"sender"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.userProfile = userProfile;
			[self redrawUserAndDate];
			[self redrawImageV];
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
}

- (void) setConversationDict:(NSDictionary *)conversationListDict
{
	if (_conversationListDict == conversationListDict)
	{
		return;
	}
	
	[_conversationListDict release];
	
	_conversationListDict = [conversationListDict retain];
	
	@autoreleasepool 
	{
		[self redrawMessage];
		
		[self redrawUserAndDate];
		
		[self requestUserProfile];
	}
}

@end
