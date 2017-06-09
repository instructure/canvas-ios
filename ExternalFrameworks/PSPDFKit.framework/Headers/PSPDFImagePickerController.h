//
//  PSPDFImagePickerController.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFImagePickerController;

/// Delegate informing about image selection and editing in `PSPDFImagePickerController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFImagePickerControllerDelegate<NSObject>

@optional

/**
 Called when the image picker selected an image from the photo library or when an image from the camera has been taken.
 Dimensions of the image are derived from the original image, without modifications.
 */
- (void)imagePickerController:(PSPDFImagePickerController *)picker didSelectImage:(UIImage *)image;

/**
 Called when the image picker did finish selecting an image or, if `shouldShowImageEditor` enabled, when the image editor finished.
 Dimensions of the image are derived from the original image, without modifications, if `shouldShowImageEditor` is disabled
 The cropped image dimensions from the image editor are used, if `shouldShowImageEditor` is enabled.
 Image annotations may be post processed to use a smaller dimension, which is not respected in this callback.
 @see `-[PSPDFAnnotationStateManager allowedImageQualities]`.
 */
- (void)imagePickerController:(PSPDFImagePickerController *)picker didFinishWithImage:(UIImage *)image andInfo:(NSDictionary<NSString *, id> *)info;

/// Called when the image picker or the image editor cancelled without selecting an image.
- (void)imagePickerControllerCancelled:(PSPDFImagePickerController *)picker;

@end

/**
 Subclass of `UIImagePickerController` used in PSPDFKit when showing the image picker, like when adding an image annotation or when adding a new page to a document from an image.

 Allows to subclass the image picker controller, for example if you need to block portrait:
 https://stackoverflow.com/questions/11467361/taking-a-photo-in-an-ios-landscape-only-app

 Shows a custom image editor after an image has been selected if `shouldShowImageEditor` is enabled.
 `delegate` is set to `self`. Don't change this, as this will restrict presenting the image editor.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFImagePickerController : UIImagePickerController

/// Set this, to be informed about the selected and, if `shouldShowImageEditor` is enabled, the edited image.
@property (nonatomic, weak) id<PSPDFImagePickerControllerDelegate> imageDelegate;

/// Controls showing the image editor after image selection. Defaults to `YES`.
@property (nonatomic) BOOL shouldShowImageEditor;

@end

NS_ASSUME_NONNULL_END
