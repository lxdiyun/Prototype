//
//  PhotoSelectSheet.m
//  Prototype
//
//  Created by Adrian Lee on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoSelector.h"

#import "Util.h"
#import "AppDelegate.h"

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
	NSObject<PhototSelectorDelegate> *_delegate;
	UIImagePickerControllerSourceType _actionArray[MAX_PHOTO_SELECT_ACTION];
	NSInteger _actionMaxIndex;
	UIPopoverController *_popoverController;
}
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIPopoverController *popoverController;
@end

@implementation PhotoSelector

@synthesize actionSheet = _actionSheet;
@synthesize imagePickerController = _imagePickerController;
@synthesize selectedImage = _selectedImage;
@synthesize delegate = _delegate;
@synthesize popoverController = _popoverController;

#pragma mark - class life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			if (nil == self.imagePickerController)
			{
				@autoreleasepool 
				{
					self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
					self.imagePickerController.allowsEditing = YES;
					self.imagePickerController.delegate = self;
				}
			}
					
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
			
			[self.actionSheet addButtonWithTitle:@"本地相册"];
			_actionArray[_actionMaxIndex] = UIImagePickerControllerSourceTypePhotoLibrary;
			++_actionMaxIndex;
			
			[self.actionSheet addButtonWithTitle:@"取消"];
			self.actionSheet.cancelButtonIndex = _actionMaxIndex;
		}
	}
	
	return self;
}


- (void) didReceiveMemoryWarning
{
	self.selectedImage = nil;
	[super didReceiveMemoryWarning];
}


-(void) dealloc
{
	self.actionSheet = nil;
	self.imagePickerController = nil;
	self.selectedImage = nil;
	self.delegate = nil;
	self.popoverController = nil;

	[super dealloc];
}

#pragma mark - View lifecycle

- (void) viewDidUnload
{
	self.actionSheet = nil;
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

- (void) showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
	if ([UIImagePickerController isSourceTypeAvailable:sourceType])
	{
		self.imagePickerController.sourceType = sourceType;
		
		if ((UIUserInterfaceIdiomPad == DEVICE_TYPE())
		    && (UIImagePickerControllerSourceTypePhotoLibrary == sourceType))
		{
			LOG(@"don't know where to show the image picker in ipad");
		}
		else 
		{
			[self.delegate showModalVC:self.imagePickerController withAnimation:YES];
		}
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
	self.selectedImage = [info valueForKey:UIImagePickerControllerEditedImage];

	// need to wait to let the view to dismiss, otherwise the ui will block
	[self.delegate didSelectPhotoWithSelector:self];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
	[self.delegate dismissModalVC:self.navigationController withAnimation:YES];
}

@end
