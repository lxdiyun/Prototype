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
const static CGFloat PADING1 = 12.0; // padding from left cell border
const static CGFloat PADING2 = 12.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 5.0; // padding from top virtical boder
const static CGFloat PADING4 = 8.0; // padding between element virtical and bottom border

@interface DetailCell () 
{
@private
	NSDictionary *_conversationListDict;
	NSDictionary *_userProfileDict;
	UILabel *_message;
	UIImageView *_bubble;
	ImageV *_avatorImageV;
}

@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UIImageView *bubble;
@property (strong, nonatomic) ImageV *avatorImageV;

@end

@implementation DetailCell

@synthesize conversationDict = _conversationListDict;
@synthesize userProfile = _userProfileDict;
@synthesize message = _message;
@synthesize bubble = _bubble;
@synthesize avatorImageV = avatorImageV;

# pragma mark - class method

+ (CGSize) getConversationSizeFor:(NSDictionary *)objectDict forCommentWidth:(CGFloat)width
{
	NSMutableString *messageString = [[objectDict valueForKey:@"msg"] mutableCopy];

	CGSize size = CGSizeMake(width, FONT_SIZE);
	
	if ((nil != messageString) && (0 < messageString.length))
	{
		CGSize constrained = CGSizeMake(width, CGFLOAT_MAX);
		size = [messageString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constrained lineBreakMode:UILineBreakModeWordWrap];
	}
	
	[messageString release];
	
	return  size;
}

+ (CGFloat) cellHeightForConversation:(NSDictionary *)objectDict forCellWidth:(CGFloat)width
{
	width = width - ((PADING1 + AVATOR_SIZE + 2 * PADING2));
	CGFloat messageHeight = [self getConversationSizeFor:objectDict forCommentWidth:width].height;
	CGFloat minmumHeight = MAX(messageHeight, AVATOR_SIZE);
	
	return minmumHeight + (PADING3 + PADING4);
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
	self.message = nil;
	self.bubble = nil;
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
	
	CGFloat X;
	CGFloat Y = [[self class] cellHeightForConversation:self.conversationDict 
					       forCellWidth:self.frame.size.width] 
	- (PADING4 / 2 + AVATOR_SIZE);
	
	NSNumber * userID = [self.conversationDict valueForKey:@"sender"];
	
	if ([userID isEqualToNumber:GET_USER_ID()])
	{
		X = self.contentView.frame.size.width * PROPORTION() - (PADING2 + AVATOR_SIZE);
	}
	else
	{
		X = PADING1;
	}
	
	self.avatorImageV = [[[ImageV alloc] initWithFrame:CGRectMake(X, 
								      Y, 
								      AVATOR_SIZE, 
								      AVATOR_SIZE)] 
			     autorelease];
	
	[self.contentView addSubview:self.avatorImageV];
	
	if (nil != self.userProfile)
	{
		NSNumber *avatarID = [self.userProfile valueForKey:@"avatar"];
		
		self.avatorImageV.picID = avatarID;
		
	}
}

- (void) redrawMessage
{
	@autoreleasepool 
	{
		if (nil != self.message)
		{
			[self.message removeFromSuperview];
		}
		
		if (nil != self.bubble)
		{
			[self.bubble removeFromSuperview];
		}

		NSString *fullMessage = nil;
		
		if (nil != self.conversationDict)
		{
			fullMessage = [self.conversationDict valueForKey:@"msg"];
		}
		
		if ((nil == fullMessage) || [fullMessage isEqualToString:@""])
		{
			// at least one character is need for display
			fullMessage = @" ";
		}
		
		UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
		CGFloat X;
		CGFloat Y;
		CGFloat maxWidth;
		CGSize bestSize;
		NSNumber * userID = [self.conversationDict valueForKey:@"sender"];
		UIImage *bubbleImage;
		UIImageView *bubbleView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
		
		if ([userID isEqualToNumber:GET_USER_ID()])
		{
			maxWidth = self.contentView.frame.size.width - ((2 * PADING2 + AVATOR_SIZE + PADING1));
			bestSize = [fullMessage sizeWithFont:font 
					   constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
					       lineBreakMode:UILineBreakModeWordWrap];
			X = self.frame.size.width * PROPORTION() - ((2 * PADING2 + AVATOR_SIZE)) - bestSize.width;
			
			bubbleImage = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 
											     topCapHeight:15];
		}
		else
		{
			X = (PADING1 + AVATOR_SIZE + PADING2);
			maxWidth = self.contentView.frame.size.width - (X + PADING2);		
			bestSize = [fullMessage sizeWithFont:font 
					   constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
					       lineBreakMode:UILineBreakModeWordWrap];
			
			bubbleImage = [[UIImage imageNamed:@"grey.png"] 
				       stretchableImageWithLeftCapWidth:24 
				       topCapHeight:15];
		}
		
		if (bestSize.height > AVATOR_SIZE)
		{
			Y = PADING3;
		}
		else
		{
			Y = (PADING3 + AVATOR_SIZE) - bestSize.height;
		}
		
		self.message = [[[UILabel alloc] 
				 initWithFrame:CGRectMake(X,
							  Y,
							  bestSize.width,
							  bestSize.height)] 
				autorelease];
		
		self.message.numberOfLines = 0;
		self.message.font = font;
		self.message.backgroundColor = [UIColor clearColor];
		self.message.adjustsFontSizeToFitWidth = NO;
		self.message.lineBreakMode = UILineBreakModeWordWrap;
		self.message.text = fullMessage;
		
		bubbleView.frame = CGRectMake(X - PADING1, 
					      Y - PADING3, 
					      bestSize.width + (PADING1 + PADING2), 
					      bestSize.height + (PADING3 + PADING4));
		bubbleView.image = bubbleImage;
		bubbleView.highlighted = YES;
		self.bubble = bubbleView;
		
		[self.contentView addSubview:self.message];
		[self.contentView addSubview:self.bubble];
		
		[self.contentView bringSubviewToFront:self.message];
	}
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
	if ([_conversationListDict isEqualToDictionary:conversationListDict])
	{
		return;
	}
	
	[_conversationListDict release];
	
	_conversationListDict = [conversationListDict retain];
	
	@autoreleasepool 
	{
		[self redrawMessage];
		[self requestUserProfile];
	}
}

@end
