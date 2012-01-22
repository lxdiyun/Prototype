//
//  CommentCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"

#import "ImageV.h"
#import "Util.h"
#import "ProfileMananger.h"

const static CGFloat AVATOR_SIZE = 44;
const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 13.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 15.0; // padding from top virtical boder
const static CGFloat PADING4 = 9.0; // padding between element virtical and bottom border

@interface CommentCell () 
{
@private
	NSDictionary *_commentDict;
	NSDictionary *_userProfileDict;
	UILabel *_userAndDate;
	UILabel *_comment;
	ImageV *_avatorImageV;
}

@property (strong, nonatomic) UILabel *userAndDate;
@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UILabel *comment;
@property (strong, nonatomic) ImageV *avatorImageV;

@end

@implementation CommentCell

@synthesize commentDict = _commentDict;
@synthesize userProfile = _userProfileDict;
@synthesize userAndDate = _userAndDate;
@synthesize comment = _comment;
@synthesize avatorImageV = avatorImageV;

# pragma mark - class method

+ (CGFloat) getCommentHeightFor:(NSDictionary *)commentDict forCommentWidth:(CGFloat)width
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

+ (CGFloat) cellHeightForComment:(NSDictionary *)commentDict forCellWidth:(CGFloat)width
{
	width = width - ((PADING1 * 2 + AVATOR_SIZE + PADING2) * PROPORTION());
	CGFloat commentHeight = [self getCommentHeightFor:commentDict forCommentWidth:width];
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
	self.commentDict = nil;
	self.userAndDate = nil;
	self.comment = nil;
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
	self.userAndDate.textColor = [Color milkColor];
	
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
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE * PROPORTION()];
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = PADING3 + FONT_SIZE + PADING4;
	CGFloat width = self.contentView.frame.size.width - ((X + PADING2) * PROPORTION());
	CGFloat height = [[self class] getCommentHeightFor:self.commentDict 
					   forCommentWidth:width];
	
	self.comment = [[[UILabel alloc] 
		      initWithFrame:CGRectMake(X * PROPORTION(),
					       Y * PROPORTION(),
					       width,
					       height)] 
		     autorelease];
	
	self.comment.numberOfLines = 0;
	self.comment.font = font;
	self.comment.backgroundColor = [UIColor clearColor];
	self.comment.textColor = [Color whiteColor];
	self.comment.lineBreakMode = UILineBreakModeWordWrap;
	
	if (nil != self.commentDict)
	{
		self.comment.text = [self.commentDict valueForKey:@"msg"];
	}

	[self.contentView addSubview:self.comment];
}

#pragma mark - message

- (void) requestUserProfile
{
	NSNumber * userID = [self.commentDict valueForKey:@"user"];
	
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

- (void) setCommentDict:(NSDictionary *)commentDict
{
	if (_commentDict == commentDict)
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

@end
