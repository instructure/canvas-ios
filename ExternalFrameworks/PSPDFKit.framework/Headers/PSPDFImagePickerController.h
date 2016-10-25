//
//  PSPDFImagePickerController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

/// Allows to subclass the image picker controller, for example if you need to block portrait:
/// https://stackoverflow.com/questions/11467361/taking-a-photo-in-an-ios-landscape-only-app
///
/// Sets `allowsEditing` in init. Subclass to change this property.
PSPDF_CLASS_AVAILABLE @interface PSPDFImagePickerController : UIImagePickerController
@end
