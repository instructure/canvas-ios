//
//  PSPDFUsernameHelper.h
//  PSPDFKit
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFViewController;

NS_ASSUME_NONNULL_BEGIN

/// Required to pick up the previous first responder.
PSPDF_EXPORT NSNotificationName const PSPDFUsernameHelperWillDismissAlertNotification;

/// A helper that can be used to present a dialog, allowing the user to specify the annotation author name.
PSPDF_CLASS_AVAILABLE @interface PSPDFUsernameHelper : NSObject

/// Access or set the default username.
/// The default will be inferred based on the device name and some internal logic.
@property (nonatomic, class, null_resettable) NSString *defaultAnnotationUsername;

/// Checks for `PSPDFDocumentDefaultAnnotationUsernameKey`.
@property (nonatomic, class, readonly) BOOL isDefaultAnnotationUserNameSet;

/// Asks for the default new annotation username, if enabled in the controller configuration if not already set.
/// The completion block gets always called, unless the dialog is shown and called.
/// Use this call if you're presenting a custom annotation creation UI (e.g., a custom toolbar).
/// Present your UI / toolbar inside the completion block.
+ (void)askForDefaultAnnotationUsernameIfNeeded:(PSPDFViewController *)pdfViewController completionBlock:(void (^)(NSString *userName))completionBlock;

/// Asks for a new default username on the provided view controller.
/// @param suggestedName A username to be pre-filled in the dialog. If `nil` we'll try to guess the username.
/// @param completionBlock Only called if successful.
- (void)askForDefaultAnnotationUsername:(UIViewController *)viewController suggestedName:(nullable NSString *)suggestedName completionBlock:(void (^)(NSString *userName))completionBlock;

@end

NS_ASSUME_NONNULL_END
