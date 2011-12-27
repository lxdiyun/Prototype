//
//  UserInfoPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UserInfoPage.h"

#import "NetworkService.h"
#import "Util.h"
#import "ImageV.h"
#import "AvatorCell.h"

UIImage *scaleAndRotateImage(UIImage *image);
@interface UIImage (Extras) 
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end


@interface  UserInfoPage   ()
{
@private
	NSArray *_userInfoArray;
	UITextView *_introduceView;
	BOOL _cellChanged;
	NSDictionary *_avatorDict;
}

@property (retain) NSArray *userInfoArray;
@property (retain) UITextView *introduceView;
@property (assign) BOOL cellChanged;
@property (retain) NSDictionary *avatorDict;

- (void)initViewDisplay;
- (void)initUserInfo;
- (void)sendUserInfoRequest;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)handleMessage:(id)dict;
- (void)refreshTableView;
- (void)performOperation:(SEL)action withObject:(id)object;
@end

@implementation UserInfoPage

@synthesize userInfoArray = _userInfoArray;
@synthesize introduceView = _introduceView;
@synthesize cellChanged = _cellChanged;
@synthesize avatorDict = _avatorDict;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (nil != self) 
	{
		// We only want our operation queue to perform one operation at a time.
		// Trying to perform a bunch of network loading operations at once in this case is a bad idea.
		NSOperationQueue *operationQueue= [[NSOperationQueue alloc] init];
		[operationQueue release];

	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	NSLog(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);
	
	[_userInfoArray release];
	[_introduceView release];
	[_avatorDict release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self initViewDisplay];

	[self initUserInfo];

	
	[self sendUserInfoRequest];

	
	self.cellChanged = YES;

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initViewDisplay
{
	[self setTitle:@"个人设置"];
	
}

- (void)initUserInfo
{
	@autoreleasepool {
		self.userInfoArray = [NSArray arrayWithObjects:
				      [NSArray arrayWithObjects:@"个人信息", @"姓名：", @"所在地：", nil],
				      [NSArray arrayWithObjects:@"头像", @"头像", nil],
				      [NSArray arrayWithObjects:@"个人介绍", @"", nil],
				      nil];
	}
}

- (void)sendUserInfoRequest
{	
	@autoreleasepool {
		uint32_t messageID = GET_MSG_ID();
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableData *messageData = [[[NSMutableData alloc] init] autorelease];
		
		// TODO update to real username
		[params setValue:@"wuvist" forKey:@"username"];
		[params setValue:@"dc6670b66d02cb02990e65272a936f36d25598d4" forKey:@"pwd"];
		
		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		[request setValue:[NSNumber numberWithUnsignedLong:messageID] forKey:@"id"];
		
		CONVERT_MSG_DICTONARY_TO_DATA(request, messageData);
		
		[[NetworkService getInstance] requestsendAndHandleMessage:messageData 
							       withTarget:self 
							      withHandler:@selector(handleMessage:) 
							    withMessageID:messageID];
	}
}

- (void)viewDidUnload
{
	NSLog(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);
	
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	[self setUserInfoArray:nil];
	[self setIntroduceView:nil];
	[self setAvatorDict:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.userInfoArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// first element is for sectoin title
	// hide for first two section user name city and avator
	if((section == 0) || (section == 1)) 
	{
		return nil;
	}
	
	return [[self.userInfoArray objectAtIndex:section] objectAtIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	// decrease one for section title
	return ([[self.userInfoArray objectAtIndex:section] count] - 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (1 == indexPath.section)
	{
		static NSString *cellType = @"AvatorCell";
		
		AvatorCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
		if (cell == nil) 
		{
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellType 
								     owner:nil 
								   options:nil];
			cell = (AvatorCell *)[nib objectAtIndex:0];
			[cell setupAvatorImageV];
		}
		
		if (nil != self.avatorDict)
		{
			cell.avatorImageV.picDict = self.avatorDict;
		}
		
		return cell;
	}
	
	NSString *CellIdentifier = [[self.userInfoArray objectAtIndex:indexPath.section] objectAtIndex:0];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		if (2 == indexPath.section)
		{
			UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
			self.introduceView = textView;

			[cell.contentView addSubview:self.introduceView];
			
			[textView release];
		}
	}

	// Configure the cell...

	if (YES == self.cellChanged)
	{
		[self configureCell:cell atIndexPath:indexPath];
	}
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
			
	case 2:
		{
			cell.textLabel.enabled =  NO;
			cell.textLabel.hidden = YES;
			
			self.cellChanged = NO;
		}
			break;
	default:
			cell.textLabel.text = [[self.userInfoArray objectAtIndex:
						indexPath.section] 
					       objectAtIndex:(indexPath.row + 1)];
			break;
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{ 
	switch (indexPath.section)
	{
	case 1:
			return 60;
			break;
	case 2:
		{
			NSString *string = [[self.userInfoArray objectAtIndex:indexPath.section]
					    objectAtIndex:1];
			
			CGRect rect = CGRectMake(0, 
						 0, 
						 self.introduceView.superview.frame.size.width, 
						 self.introduceView.superview.frame.size.height);
			
			// configure text view display
			self.introduceView.frame = rect;
			self.introduceView.font = [UIFont boldSystemFontOfSize:17.0];
			self.introduceView.userInteractionEnabled = NO;
			self.introduceView.editable = NO;
			self.introduceView.scrollEnabled = NO;
			self.introduceView.backgroundColor = [UIColor clearColor];
			self.introduceView.text = string;
			
			CGRect frame = self.introduceView.frame;
			frame.size.height = self.introduceView.contentSize.height;
			self.introduceView.frame = frame;
			
			return MAX(self.introduceView.frame.size.height, 44);
			break;
		}
		
	default:
			return 44;
	}
	
	

}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

// did not provide selectable cell
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return Nil;
}

- (void)handleMessage:(id)dict
{

	if (![dict isKindOfClass: [NSDictionary class]])
	{
		NSLog(@"Error handle non dict object");
		return;
	}
	
	NSDictionary *messageDict = (NSDictionary*)dict;
	
	NSString *userName = [NSString stringWithFormat:@"姓名：%@", [[messageDict objectForKey:@"result"] objectForKey:@"nick"]];
	NSString *city = [NSString stringWithFormat:@"所在地：%@", [[messageDict objectForKey:@"result"] objectForKey:@"city"]];
	
	NSString *introduceString = [[messageDict objectForKey:@"result"] objectForKey:@"intro"];
	
	self.userInfoArray = [NSArray arrayWithObjects:
			      [NSArray arrayWithObjects:@"个人信息", userName, city, nil],
			      [NSArray arrayWithObjects:@"头像", @"头像", nil],
			      [NSArray arrayWithObjects:@"个人介绍", introduceString, nil],
			      nil];
	
	self.avatorDict = [[messageDict objectForKey:@"result"] objectForKey:@"avatar"];
	
	self.cellChanged = YES;
	
	[self refreshTableView];
	
	// TODO: remove Log
	// NSString *messageID = [messageDict objectForKey:@"id"];
	// NSLog(@"Message Dict = %@", messageDict);
	// NSLog(@"City is = %@", city);
	// NSLog(@"Avator Url = %@", self.avatorUrl);
	// NSLog(@"Message id = %@",  messageID);
}

- (void)refreshTableView
{
	NSLog(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);

	if (YES == [self.view isKindOfClass:[UITableView class]])
	{
		[(UITableView *)self.view reloadData];
	}
}

- (void)performOperation:(SEL)action withObject:(id)object
{
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self 
										selector:action
										  object:object];
	PERFORM_OPERATION(operation);
	[operation release];
}

UIImage *scaleAndRotateImage(UIImage *image)  
{  
        int kMaxResolution = 50; // Or whatever  
	
        CGImageRef imgRef = image.CGImage;  
	
        CGFloat width = CGImageGetWidth(imgRef);  
        CGFloat height = CGImageGetHeight(imgRef);  
	
        CGAffineTransform transform = CGAffineTransformIdentity;  
        CGRect bounds = CGRectMake(0, 0, width, height);  
        if (width > kMaxResolution || height > kMaxResolution) {  
		CGFloat ratio = width/height;  
		if (ratio > 1) {  
			bounds.size.width = kMaxResolution;  
			bounds.size.height = bounds.size.width / ratio;  
		}  
		else {  
			bounds.size.height = kMaxResolution;  
			bounds.size.width = bounds.size.height * ratio;  
		}  
        }  
	
        CGFloat scaleRatio = bounds.size.width / width;  
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
        CGFloat boundHeight;  
        UIImageOrientation orient = image.imageOrientation;  
        switch(orient) {  
			
		case UIImageOrientationUp: //EXIF = 1  
			transform = CGAffineTransformIdentity;  
			break;  
			
		case UIImageOrientationUpMirrored: //EXIF = 2  
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
			transform = CGAffineTransformScale(transform, -1.0, 1.0);  
			break;  
			
		case UIImageOrientationDown: //EXIF = 3  
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
			transform = CGAffineTransformRotate(transform, M_PI);  
			break;  
			
		case UIImageOrientationDownMirrored: //EXIF = 4  
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
			transform = CGAffineTransformScale(transform, 1.0, -1.0);  
			break;  
			
		case UIImageOrientationLeftMirrored: //EXIF = 5  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
			transform = CGAffineTransformScale(transform, -1.0, 1.0);  
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
			break;  
			
		case UIImageOrientationLeft: //EXIF = 6  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
			break;  
			
		case UIImageOrientationRightMirrored: //EXIF = 7  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeScale(-1.0, 1.0);  
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
			break;  
			
		case UIImageOrientationRight: //EXIF = 8  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
			break;  
			
		default:  
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
        }  
	
        UIGraphicsBeginImageContext(bounds.size);  
	
        CGContextRef context = UIGraphicsGetCurrentContext();  
	
        if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {  
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
		CGContextTranslateCTM(context, -height, 0);  
        }  
        else {  
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
		CGContextTranslateCTM(context, 0, -height);  
        }  
	
        CGContextConcatCTM(context, transform);  
	
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
        UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
        UIGraphicsEndImageContext();  
	
        return imageCopy;  
}  

@end


@implementation UIImage (Extras) 
#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
        {
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
		else
			scaleFactor = heightFactor; // scale to fit width
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		if (widthFactor > heightFactor)
                {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
                }
		else 
			if (widthFactor < heightFactor)
                        {
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
                        }
        }       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
		NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}
@end
