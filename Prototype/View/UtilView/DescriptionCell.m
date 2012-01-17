//
//  DescriptionCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DescriptionCell.h"

#import "ImageV.h"
#import "Util.h"
#import "ProfileMananger.h"
#import "TriangleView.h"

const static CGFloat AVATOR_SIZE = 50;
const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 =  15.0; // padding from top virtical boder
const static CGFloat PADING4 = 9.0; // padding between element virtical and bottom border
const static CGFloat IMAGE_BORDER = 3.0;
const static CGFloat TRIANGLE_HEIGHT = 10.0;
const static CGFloat TRIANGLE_WIDTH = 20.0;

@interface DescriptionCell () 
{
@private
	NSDictionary *_objectDict;
	NSDictionary *_userProfileDict;
	UILabel *_userAndDate;
	UILabel *_description;
	ImageV *_avatorImageV;
	TriangleView *_triangle;
}

@property (strong, nonatomic) UILabel *userAndDate;
@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UILabel *description;
@property (strong, nonatomic) ImageV *avatorImageV;
@property (strong, nonatomic) TriangleView *triangle;
@end


@implementation DescriptionCell

@synthesize objectDict = _objectDict;
@synthesize userProfile = _userProfileDict;
@synthesize userAndDate = _userAndDate;
@synthesize description = _comment;
@synthesize avatorImageV = avatorImageV;
@synthesize triangle = _triangle;

# pragma mark - class method

+ (CGFloat) getDescriptionHeightFor:(NSDictionary *)commentDict forDescWidth:(CGFloat)width
{
	NSString *descString = [commentDict valueForKey:@"desc"];
	CGFloat descHeight = FONT_SIZE * PROPORTION();
	
	if ((nil != descString) &&  (0 < descString.length))
	{
		CGSize constrained = CGSizeMake(width, 9999.0);
		descHeight = [descString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE * PROPORTION()] constrainedToSize:constrained lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	return  descHeight;
}

+ (CGFloat) cellHeightForObject:(NSDictionary *)objectDict forCellWidth:(CGFloat)width
{
	width = width - ((PADING1 * 2 + AVATOR_SIZE + PADING2) * PROPORTION());
	CGFloat descHeight = [self getDescriptionHeightFor:objectDict forDescWidth:width];
	
	return descHeight + (FONT_SIZE + PADING4 + PADING3 * 2) * PROPORTION();
}

#pragma mark - life circle

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) 
	{
		self.contentView.backgroundColor = [Color whiteColor];
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
	self.objectDict = nil;
	self.userAndDate = nil;
	self.description = nil;
	self.avatorImageV = nil;
	self.triangle = nil;
	
	[super dealloc];
}

#pragma mark - draw cell
- (void) redrawTriangleFrom:(CGFloat)fromHeight
{
	if (nil != self.triangle)
	{
		[self.triangle removeFromSuperview];
	}
	
	CGFloat X = self.contentView.frame.size.width / PROPORTION() - TRIANGLE_WIDTH - PADING2;
	CGFloat Y = fromHeight + (PADING3 * PROPORTION()) - (TRIANGLE_HEIGHT * PROPORTION());
	CGRect rect = CGRectMake(X * PROPORTION(), 
				 Y, 
				 TRIANGLE_WIDTH * PROPORTION(), 
				 TRIANGLE_HEIGHT * PROPORTION());
	
	self.triangle = [[[TriangleView alloc] initWithFrame:rect 
						    andColor:[Color orangeColor]] 
			 autorelease];
	
	[self.contentView addSubview:self.triangle];
}

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
	
	[self.avatorImageV.layer setBorderColor:[[Color blackColorAlpha] CGColor]];
	[self.avatorImageV.layer setBorderWidth: IMAGE_BORDER * PROPORTION()];
	
	[self.contentView addSubview:self.avatorImageV];
	
	if (nil != self.userProfile)
	{
		self.avatorImageV.picID = [self.userProfile valueForKey:@"avatar"];
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
	CGFloat width = self.contentView.frame.size.width / PROPORTION()  - X - PADING1;
	CGFloat height = FONT_SIZE;
	
	self.userAndDate = [[[UILabel alloc] init] autorelease];
	self.userAndDate.frame = CGRectMake(X * PROPORTION(),
					    Y * PROPORTION(),
					    width * PROPORTION(),
					    height * PROPORTION());
	
	self.userAndDate.font = font;
	self.userAndDate.adjustsFontSizeToFitWidth = YES;
	self.userAndDate.backgroundColor = [UIColor clearColor];
	self.userAndDate.textColor = [Color grey2Color];
	
	NSString *nick = @"";
	NSString *createTime  = @"";
	if (nil != self.userProfile)
	{
		nick = [self.userProfile valueForKey:@"nick"];
	}
	
	if (nil != self.objectDict)
	{
		createTime = [self.objectDict valueForKey:@"created_on"];
	}
	
	self.userAndDate.text = [NSString stringWithFormat:@"%@  %@", nick, createTime];
	
	[self.contentView addSubview:self.userAndDate];
}

- (void) redrawDescription
{
	if (nil != self.description)
	{
		[self.description removeFromSuperview];
	}
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE * PROPORTION()];
	CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
	CGFloat Y = (FONT_SIZE + PADING3 + PADING4) * PROPORTION();
	CGFloat width = self.contentView.frame.size.width - ((X + PADING1) * PROPORTION());
	CGFloat height = [[self class] getDescriptionHeightFor:self.objectDict
						  forDescWidth:width];
	
	self.description = [[[UILabel alloc] 
			 initWithFrame:CGRectMake(X * PROPORTION(),
						  Y,
						  width,
						  height)] 
			autorelease];
	
	self.description.numberOfLines = 0;
	self.description.font = font;
	self.description.backgroundColor = [UIColor clearColor];
	self.description.lineBreakMode = UILineBreakModeWordWrap;
	
	if (nil != self.objectDict)
	{
		self.description.text = [self.objectDict valueForKey:@"desc"];
	}
	
	[self.contentView addSubview:self.description];
	
	[self redrawTriangleFrom:(Y + height)];
}

#pragma mark - message

- (void) requestUserProfile
{
	NSNumber * userID = [self.objectDict valueForKey:@"user"];
	
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

- (void) setObjectDict:(NSDictionary *)objectDict
{
	if (_objectDict == objectDict)
	{
		return;
	}
	
	[_objectDict release];
	
	_objectDict = [objectDict retain];
	
	@autoreleasepool 
	{
		[self redrawDescription];
		
		[self redrawUserAndDate];
	
		[self requestUserProfile];
	}
}

@end
