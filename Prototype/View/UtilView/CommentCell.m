//
//  CommentCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"

#import "ProfileMananger.h"
#import "AvatarV.h"

const static CGFloat AVATOR_SIZE = 30;
const static CGFloat FONT_SIZE = 12.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right border
const static CGFloat PADING3 = 5.0; // padding from top virtical border and padding between element virtical
const static CGFloat PADING4 = 10.0; //  bottom border

@interface CommentCell ()
{
@private
	NSDictionary *_commentDict;
	NSDictionary *_userProfileDict;
	UILabel *_userAndDate;
	UILabel *_comment;
	AvatarV *_avatar;
	id<ShowVCDelegate> _delegate;
}

@property (strong, nonatomic) UILabel *userAndDate;
@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UILabel *comment;
@property (strong, nonatomic) AvatarV *avatar;

@end

@implementation CommentCell

@synthesize commentDict = _commentDict;
@synthesize userProfile = _userProfileDict;
@synthesize userAndDate = _userAndDate;
@synthesize comment = _comment;
@synthesize avatar = avatorImageV;
@synthesize delegate = _delegate;

# pragma mark - class method

+ (CGFloat) getCommentHeightFor:(NSDictionary *)commentDict forCommentWidth:(CGFloat)width
{
	NSString *commentString = [commentDict valueForKey:@"msg"];
	CGFloat commentHeight = FONT_SIZE;
	
	if ((nil != commentString) && (0 < commentString.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		// remove 1.0 pixcel of padding
		commentHeight = [commentString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] 
					  constrainedToSize:constrained 
					      lineBreakMode:UILineBreakModeWordWrap].height - 1.0;
	}
	
	return  commentHeight;
}

+ (CGFloat) cellHeightForComment:(NSDictionary *)commentDict forCellWidth:(CGFloat)width
{
	width = width - (PADING1 * 2 + AVATOR_SIZE + PADING2);
	CGFloat commentHeight = [self getCommentHeightFor:commentDict forCommentWidth:width];
	
	return commentHeight + (FONT_SIZE + PADING4 + PADING3 * 2);
}

# pragma mark - life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (nil != self) 
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.contentView.backgroundColor = [Color orange];
		[self redrawAvatar];
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
	self.commentDict = nil;
	self.userAndDate = nil;
	self.comment = nil;
	self.avatar = nil;
	
	[super dealloc];
}

#pragma mark - draw cell

- (void) redrawAvatar
{
	@autoreleasepool 
	{
		if (nil != self.avatar)
		{
			[self.avatar removeFromSuperview];
		}
		
		self.avatar = [AvatarV createFromXibWithFrame:CGRectMake(PADING1, 
									 PADING3, 
									 AVATOR_SIZE, 
									 AVATOR_SIZE)];
		
		[self.contentView addSubview:self.avatar];
	}
}

- (void) redrawUserAndDate
{
	if (nil != self.userAndDate)
	{
		self.userAndDate.text = @"";
		[self.userAndDate removeFromSuperview];
	}
	
	UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
	
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = PADING3;
	CGFloat width = self.contentView.frame.size.width - (X + PADING2);
	CGFloat height = FONT_SIZE;
	
	self.userAndDate = [[[UILabel alloc] init] autorelease];
	self.userAndDate.frame = CGRectMake(X,
					    Y,
					    width,
					    height);
	
	self.userAndDate.font = font;
	self.userAndDate.adjustsFontSizeToFitWidth = YES;
	self.userAndDate.backgroundColor = [UIColor clearColor];
	self.userAndDate.textColor = [Color milk];
	
	NSString *nick = @"";
	NSString *createTime  = @"";

	if (nil != self.userProfile)
	{
		nick = [self.userProfile valueForKey:@"nick"];
	}
	
	if (nil != self.commentDict)
	{
		createTime = [self.commentDict valueForKey:@"created_on_str"];
	}
	
	self.userAndDate.text = [NSString stringWithFormat:@"%@  %@", nick, createTime];
	
	[self.contentView addSubview:self.userAndDate];
}

- (void) redrawComment
{
	if (nil != self.comment)
	{
		[self.comment removeFromSuperview];
	}
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = PADING3 + FONT_SIZE + PADING3;
	CGFloat width = self.contentView.frame.size.width - (X + PADING2);
	CGFloat height = [[self class] getCommentHeightFor:self.commentDict 
					   forCommentWidth:width];	
	
	self.comment = [[[UILabel alloc] 
			 initWithFrame:CGRectMake(X,
						  Y,
						  width,
						  height)] 
			autorelease];
	
	self.comment.numberOfLines = 0;
	self.comment.font = font;
	self.comment.backgroundColor = [UIColor clearColor];
	self.comment.textColor = [UIColor whiteColor];
	self.comment.lineBreakMode = UILineBreakModeWordWrap;
	
	if (nil != self.commentDict)
	{
		self.comment.text = [self.commentDict valueForKey:@"msg"];
	}
	
	[self.contentView addSubview:self.comment];
}

#pragma mark - manage object

- (void) requestUserProfile
{
	NSNumber * userID = [self.commentDict valueForKey:@"user"];
	
	if (nil != userID)
	{
		NSDictionary * userProfile = [ProfileMananger getObjectWithNumberID:userID];
		
		if (nil != userProfile)
		{
			self.userProfile = userProfile;

			self.avatar.user = self.userProfile;

			[self redrawUserAndDate];
		}
		else
		{
			self.avatar.user = nil;

			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:@selector(requestUserProfile) 
							 andTarget:self];
		}
	}
}

- (void) setCommentDict:(NSDictionary *)commentDict
{
	if (CHECK_EQUAL(_commentDict, commentDict))
	{
		return;
	}
	
	[_commentDict release];
	
	_commentDict = [commentDict retain];
	
	@autoreleasepool 
	{
		[self redrawComment];
		
		[self redrawUserAndDate];
		
		[self requestUserProfile];
	}
}

- (void) setDelegate:(id<ShowVCDelegate>)delegate
{
	if ([_delegate isEqual:delegate])
	{
		return;
	}
	
	_delegate = delegate;
	
	self.avatar.delegate = delegate;
}

@end
