//
//  PhotoSelectSheet.m
//  Prototype
//
//  Created by Adrian Lee on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoSelector.h"

#import "Util.h"

typedef enum PHOTO_SELECT_ACTION_ENUM
{
	TAKE_PHOTO = 0x0,
	UPLOAD_EXIST_PHOTO = 0x1,
	MAX_PHOTO_SELECT_ACTION
} PHTOT_SELECT_ACTION;

@interface PhotoSelector () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UIActionSheet *_actionSheet;
	UIImagePickerController *_imagePickerController;
	UIImage *_selectedImage;
	UIViewController<PhototSelectorDelegate> * _delegate;
	UIImagePickerControllerSourceType _actionArray[MAX_PHOTO_SELECT_ACTION];
	NSInteger _actionMaxIndex;
}
@property (strong) UIImagePickerController *imagePickerController;
@end

@implementation PhotoSelector

@synthesize actionSheet = _actionSheet;
@synthesize imagePickerController = _imagePickerController;
@synthesize selectedImage = _selectedImage;
@synthesize delegate = _delegate;

#pragma mark - class life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
					
			self.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
									delegate:self 
							       cancelButtonTitle:nil 
							  destructiveButtonTitle:nil 
							       otherButtonTitles:nil] 
					    autorelease];
			
			self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			
			_actionMaxIndex = 0;
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				[self.actionSheet addButtonWithTitle:@"拍照"];
				_actionArray[_actionMaxIndex] = UIImagePickerControllerSourceTypeCamera;
				++_actionMaxIndex;
			}
			
			[self.actionSheet addButtonWithTitle:@"本地上传"];
			_actionArray[_actionMaxIndex] = UIImagePickerControllerSourceTypePhotoLibrary;
			++_actionMaxIndex;
			
			[self.actionSheet addButtonWithTitle:@"取消"];
			self.actionSheet.cancelButtonIndex = _actionMaxIndex;
		}
	}
	
	return self;
}


- (void)didReceiveMemoryWarning
{
	self.selectedImage = nil;
	self.imagePickerController = nil;
	[super didReceiveMemoryWarning];
}


-(void) dealloc
{
	self.actionSheet = nil;
	self.imagePickerController = nil;
	self.selectedImage = nil;
	self.delegate = nil;

	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	self.actionSheet = nil;
	self.imagePickerController = nil;
	self.selectedImage = nil;
	self.delegate = nil;
	
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
		if (nil == self.imagePickerController)
		{
			@autoreleasepool 
			{
				self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
			}
		}
		self.imagePickerController.sourceType = sourceType;

		self.imagePickerController.delegate = self;
		[self.delegate presentModalViewController:self.imagePickerController animated:YES];
	}
}

#pragma mark - UIActionSheetDelegate methods

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ((0 <= buttonIndex) && (_actionMaxIndex > buttonIndex))
	{
		[self showImagePicker:(_actionArray[buttonIndex])];
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker 
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{	
	self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	// release the picker or will receive mermory warning
	self.imagePickerController = nil;
	
	[self.delegate dismissModalViewControllerAnimated:YES];
	
	[self.delegate performSelector:@selector(didSelectPhotoWithSelector:) 
			    withObject:self
			    afterDelay:1.0];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

@end
