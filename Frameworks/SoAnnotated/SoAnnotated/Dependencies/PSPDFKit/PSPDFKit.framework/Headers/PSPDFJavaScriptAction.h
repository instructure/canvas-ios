//
//  PSPDFJavaScriptAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"
#import "PSPDFFormElement.h"
#import "PSPDFDocument.h"
#import "PSPDFApplicationJSExport.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPDFDocumentProvider (JavascriptEventsAdditions)

/// Used to automatically process the actions that follow a keystroke or selection change (for choice fields)
/// Must pass appropriate values in the eventParams dictionary. In particular, `willCommit` and `change`, should be set correctly.
/// The returned dictionary contains the response code and the modified change value possibly
/// Handles K and V actions.
- (nullable NSDictionary<NSString *, id> *)executeValueChangedJSActionSequenceWithActionContainer:(nullable id)actionContainer application:(nullable id<PSPDFApplicationJSExport>)application eventParams:(nullable NSDictionary<NSString *, id> *)eventParams error:(NSError **)error;

/// Executes the format action for the container. If no action exists, returns the value unchanged.
/// Handles F actions from the additional actions dictionary.
- (nullable NSString *)executeFormatActionWithActionContainer:(nullable id)actionContainer application:(nullable id<PSPDFApplicationJSExport>)application eventParams:(nullable NSDictionary<NSString *, id> *)eventParams error:(NSError **)error;

/// Note for the calculation method below (Adobe Acrobat SDK JavaScript API - JavaScript for Acrobat API Reference) :
///
/// This event is defined when a change in a form requires that all fields that have a calculation script attached to them be executed. All fields that depend on the value of the changed field will now be recalculated. These fields may in turn generate additional Field/Validate, Field/Blur, and Field/Focus events. Calculated fields may have dependencies on other calculated fields whose values must be determined beforehand. The calculation order array contains an ordered list of all the fields in a document that have a
/// calculation script attached. When a full calculation is needed, each of the fields in the array is calculated in turn starting with the zeroth index of the array and continuing in sequence to the end of the array.

/// Executes all calculate actions in the document that depend on the `sourceForm` value.
/// For performance reasons, this method isn't automatically executed on creation time. If you need up-to-date form values
/// be sure to call this method at least once (passing `nil` as the `sourceForm`) before accessing the form values.
/// `PSPDFViewController` will do this for you automatically, if you are displaying the document.
/// @note Executes synchronously. Use with caution for complex actions, as it blocks the main thread. (Must be run on main thread).
/// @return YES if successful.
- (BOOL)updateCalculatedFieldsDependingOnForm:(nullable PSPDFFormElement *)sourceForm error:(NSError **)error;

@end

/// Defines an action that contains JavaScript to be executed in the document context.
PSPDF_CLASS_AVAILABLE @interface PSPDFJavaScriptAction : PSPDFAction

/// Designated initializer.
- (instancetype)initWithScript:(NSString *)script;

/// The javascript content.
@property (nonatomic, copy, readonly, nullable) NSString *script;

/// Tries to execute the JavaScript in the context of a document provider.
/// Use the event params to override certain values for the event object in the executed script.
- (NSDictionary<NSString *, id> *)executeScriptAppliedToDocumentProvider:(PSPDFDocumentProvider *)documentProvider application:(nullable id<PSPDFApplicationJSExport>)application eventDictionary:(nullable NSDictionary<NSString *, id> *)eventDictionary sender:(id)sender error:(NSError **)error;

@end

/// The following string constants represent the keys for the event dictionary
/// corresponding to the action event.
/// Form the Adobe Javascript for Acrobat Reference:
///
/// All JavaScript scripts are executed as the result of a particular event. For each of these events, JavaScript creates an event object. During the occurrence of each event, you can access this object to get and possibly manipulate information about the current state of the event. Each event has a type and a name property that uniquely identify the event.


/// For the Field/Validate event, it is the value that the field contains when it is committed. For a
/// combo box, it is the face value, not the export value. For a keystroke event, it is the value, before the keystroke is committed.
PSPDF_EXPORT NSString *const PSPDFActionEventValueKey;

/// The name of the current event as a text string. The type and name together uniquely identify the event.
/// The valid values defined at the end of this file.
/// Valid names are:  Keystroke, Validate, Focus, Blur, Format, Calculate, Mouse Up, Mouse Down, Mouse Enter, Mouse Exit, WillPrint, DidPrint, WillSave, DidSave, Init, Exec, Open, Close
PSPDF_EXPORT NSString *const PSPDFActionEventNameKey;

/// The type of the current event. The type and name together uniquely identify the event. Valid types are:
/// Batch, External, Console, Bookmark, App, Link, Doc, Field, Page, Menu
PSPDF_EXPORT NSString *const PSPDFActionEventTypeKey;
PSPDF_EXPORT NSString *const PSPDFActionEventSourceKey;
PSPDF_EXPORT NSString *const PSPDFActionEventTargetKey;
PSPDF_EXPORT NSString *const PSPDFActionEventTargetNameKey;
PSPDF_EXPORT NSString *const PSPDFActionEventRCKey;
PSPDF_EXPORT NSString *const PSPDFActionEventChangeKey;
PSPDF_EXPORT NSString *const PSPDFActionEventWillCommitKey;
PSPDF_EXPORT NSString *const PSPDFActionEventSelStartKey;
PSPDF_EXPORT NSString *const PSPDFActionEventSelEndKey;

/// The following string constants represent values for the action event dictionary keys with fixed discrete range.
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueMouseDown;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueMouseUp;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueMouseEnter;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueMouseExit;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueFormat;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueCalculate;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueValidate;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueKeystroke;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueBlur;
PSPDF_EXPORT NSString *const PSPDFActionEventNameValueFocus;

/// Type Values
PSPDF_EXPORT NSString *const PSPDFActionEventTypeValueField;

/// The domain for errors originating from javascript execution in the context of `PSPDFJavaScriptAction`.
PSPDF_EXPORT NSString *const PSPDFJavascriptErrorDomain;

typedef NS_ENUM(NSInteger, PSPDFJavascriptErrorCode) {
    PSPDFJavascriptErrorScriptExecutionFailed = 100
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_END
