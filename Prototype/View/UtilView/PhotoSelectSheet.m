//
//  PhotoSelectSheet.m
//  Prototype
//
//  Created by Adrian Lee on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoSelectSheet.h"

#import "Util.h"

typedef enum PHOTO_SELECT_ACTION_ENUM
{
	TAKE_PHOTO = 0x0,
	UPLOAD_EXIST_PHOTO = 0x1
} PHTOT_SELECT_ACTION;

@interface PhotoSelectSheet () <UIActionSheetDelegate, UIImagePickerControllerDelegate>
{
	UIActionSheet *_actionSheet;
	UIImagePickerController *_imagePickerController;
	UIImage *_selectedImage;
}
@property (strong) UIImagePickerController *imagePickerController;
@end

@implementation PhotoSelectSheet

@synthesize actionSheet = _actionSheet;
@synthesize imagePickerController = _imagePickerController;
@synthesize selectedImage = _selectedImage;

#pragma mark - class life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			
			self.actionSheet = [[[UIActionSheet alloc] initWithTitle:@"select Photo" 
									delegate:self 
							       cancelButtonTitle:@"取消" 
							  destructiveButtonTitle:nil 
							       otherButtonTitles:@"拍照", @"本地上传", nil] 
					    autorelease];
			self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			
			if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				// TODO remove camera button
			}
			
			self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
		}
	}
	
	return self;
}


- (void)didReceiveMemoryWarning
{
	self.selectedImage = nil;
	[super didReceiveMemoryWarning];
}


-(void) dealloc
{
	self.actionSheet = nil;
	self.imagePickerController = nil;
	self.selectedImage = nil;

	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	self.actionSheet = nil;
	self.imagePickerController = nil;
	self.selectedImage = nil;
	
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - image picker methods

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
	if ([UIImagePickerController isSourceTypeAvailable:sourceType])
	{
		self.imagePickerController.sourceType = sourceType;
		
		/* TODO handle camera
		if (sourceType == UIImagePickerControllerSourceTypeCamera)
		{
			// user wants to use the camera interface
			self.imagePickerController.showsCameraControls = NO;
			
			if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0)
			{
				// setup our custom overlay view for the camera
				//
				// ensure that our custom view's frame fits within the parent frame
				CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
				CGRect newFrame = CGRectMake(0.0,
							     CGRectGetHeight(overlayViewFrame) -
							     self.view.frame.size.height - 10.0,
							     CGRectGetWidth(overlayViewFrame),
							     self.view.frame.size.height + 10.0);
				self.view.frame = newFrame;
				[self.imagePickerController.cameraOverlayView addSubview:self.view];
			}
		}
		 */

		LOG(@"upload selected");
		[[self.actionSheet superview] presentModalViewController:self.imagePickerController animated:YES];
	}
}

#pragma mark - UIActionSheetDelegate methods

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case TAKE_PHOTO:
			[self showImagePicker:UIImagePickerControllerSourceTypeCamera];
			
			break;
		case UPLOAD_EXIST_PHOTO:
			[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
			
		default:
			break;
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker 
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{	
	self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
