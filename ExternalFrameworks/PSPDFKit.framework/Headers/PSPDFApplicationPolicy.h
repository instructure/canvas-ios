//
//  PSPDFApplicationPolicy.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPlugin.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_EXPORT NSString *const PSPDFPolicyEventOpenIn;
PSPDF_EXPORT NSString *const PSPDFPolicyEventPrint;
PSPDF_EXPORT NSString *const PSPDFPolicyEventEmail;
PSPDF_EXPORT NSString *const PSPDFPolicyEventMessage;
PSPDF_EXPORT NSString *const PSPDFPolicyEventQuickLook;
PSPDF_EXPORT NSString *const PSPDFPolicyEventAudioRecording;
PSPDF_EXPORT NSString *const PSPDFPolicyEventCamera;
PSPDF_EXPORT NSString *const PSPDFPolicyEventPhotoLibrary;
PSPDF_EXPORT NSString *const PSPDFPolicyEventPasteboard; // includes Copy/Paste
PSPDF_EXPORT NSString *const PSPDFPolicyEventSubmitForm;
PSPDF_EXPORT NSString *const PSPDFPolicyEventNetwork;

/// The security auditor protocol allows to define a custom set of overrides for various security related tasks.
PSPDF_AVAILABLE_DECL @protocol PSPDFApplicationPolicy <PSPDFPlugin>

/// Returns YES when the `PSPDFPolicyEvent` is allowed.
/// `isUserAction` is a hint that indicates if we're in a user action or an automated test.
/// If it's a user action, it is appropriate to present an alert explaining the lack of permissions.
- (BOOL)hasPermissionForEvent:(NSString *)event isUserAction:(BOOL)isUserAction;

@end

/// The default security auditor simply returns YES for every request.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultApplicationPolicy : NSObject <PSPDFApplicationPolicy>
@end

NS_ASSUME_NONNULL_END
