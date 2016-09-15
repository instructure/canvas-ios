//
//  PSPDFApplicationJSExport.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@class PSPDFFormElement;

/// `JSExport` is an empty protocol, we extend it and add methods we and exposed in Javascript for the application object
/// (Usually, this will be the `PSPDFViewController`)
PSPDF_AVAILABLE_DECL @protocol PSPDFApplicationJSExport <JSExport, NSObject>

/// There are three cases for methods we wish to export to JavaScript.
///
/// 1) The method exists for `PSPDFViewController` and the exported method name should be the same
/// eg. `- (NSUInteger)displayingPage`
///
/// In this case, it is not needed to add the method to the category implementing the protocol, since it's already implemented.
/// This approach is avoided to promote a clear and controlled interface between JS and PSPDFKit.
///
/// 2) The method exists for `PSPDFViewController` but the name must change.
///
/// In this case, we use the following macro: `JSExportAs(PropertyName, Selector)`
/// eg.
/// ```
/// JSExportAs(doFoo,
/// - (void)doFoo:(id)foo withBar:(id)bar
/// );
/// ```
///
/// 3) The method does no exist for `PSPDFViewController`
///
/// In this case, we simply add the method both to the protocol and the category and finally implement the method.

@property (nonatomic) NSUInteger pageNum;
- (nullable PSPDFFormElement *)getField:(NSString *)name;
- (void)print:(id)params;

/// Saves the current PDF document and mails it as an attachment to all recipients, with or without user interaction.
/**
 bUI (optional) If true (the default), the rest of the parameters are used in a
 compose-new-message window that is displayed to the user. If false, the cTo
 parameter is required and all others are optional.
 Note: (Acrobat 7.0) When this method is executed in a non-privileged context, the
 bUI parameter is not honored and defaults to true. See “Privileged versus
 non-privileged context” on page 32.
 cTo (optional) The semicolon-delimited list of recipients for the message.
 cCc (optional) The semicolon-delimited list of CC recipients for the message.
 cBcc (optional) The semicolon-delimited list of BCC recipients for the message.
 cSubject (optional) The subject of the message. The length limit is 64 KB.
 cMsg (optional) The content of the message. The length limit is 64 KB
 
 Open the compose message window.
 this.mailDoc(true);
 Send email with the attached PDF file to apstory@example.com and dpsmith@example.com.
 Beginning with Acrobat 7.0, the code below would have to be executed in a privileged context if the bUI
 parameter (set to false) is to be honored.
 this.mailDoc({
 bUI: false,
 cTo: "apstory@example.com",
 cCC: "dpsmith@example.com",
 cSubject: "The Latest News",
 cMsg: "A.P., attached is my latest news story in PDF."
 });
 
 Can also be in this format:
 this.mailDoc(true, "info@domain.com", "", "", "Message Subject Description");
 */
- (void)mailDoc:(NSDictionary *)params;

- (void)resetForm:(NSArray<NSString *> *)names;
- (void)alert:(id)params;
- (NSUInteger)viewerVersion;

JSExportAs(buttonImportIcon,
           - (NSInteger)buttonImportIcon:(nullable NSString *)cPath page:(NSNumber *)nPage sourceForm:(PSPDFFormElement *)formElement
           );

JSExportAs(launchURL,
           - (void)launchURL:(NSString *)cURL newFrame:(nullable NSNumber *)bNewFrame
           );

@end

NS_ASSUME_NONNULL_END
