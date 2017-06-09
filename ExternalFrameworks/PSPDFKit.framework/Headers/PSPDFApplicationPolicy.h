//
//  PSPDFApplicationPolicy.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Policy for Open In.
PSPDF_EXPORT NSString *const PSPDFPolicyEventOpenIn;
/// Policy for print.
PSPDF_EXPORT NSString *const PSPDFPolicyEventPrint;
/// Policy for mail.
PSPDF_EXPORT NSString *const PSPDFPolicyEventEmail;
/// Policy for message.
PSPDF_EXPORT NSString *const PSPDFPolicyEventMessage;
/// Policy for Quick Look.
PSPDF_EXPORT NSString *const PSPDFPolicyEventQuickLook;
/// Policy for audio recording.
PSPDF_EXPORT NSString *const PSPDFPolicyEventAudioRecording;
/// Policy for the camera.
PSPDF_EXPORT NSString *const PSPDFPolicyEventCamera;
/// Policy for the photo library.
PSPDF_EXPORT NSString *const PSPDFPolicyEventPhotoLibrary;
/// Policy for the pasteboard. Includes Copy/Paste.
PSPDF_EXPORT NSString *const PSPDFPolicyEventPasteboard;
/// Policy for submitting forms.
PSPDF_EXPORT NSString *const PSPDFPolicyEventSubmitForm;
/// Policy for the network.
PSPDF_EXPORT NSString *const PSPDFPolicyEventNetwork;

/// The security auditor protocol allows to define a custom set of overrides for various security related tasks.
PSPDF_AVAILABLE_DECL @protocol PSPDFApplicationPolicy

/**
 Returns YES when the `PSPDFPolicyEvent` is allowed.
 `isUserAction` is a hint that indicates if we're in a user action or an automated test.
 If it's a user action, it is appropriate to present an alert explaining the lack of permissions.
 */
- (BOOL)hasPermissionForEvent:(NSString *)event isUserAction:(BOOL)isUserAction;

@end

/// The default security auditor simply returns YES for every request.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultApplicationPolicy : NSObject<PSPDFApplicationPolicy>
@end

NS_ASSUME_NONNULL_END
