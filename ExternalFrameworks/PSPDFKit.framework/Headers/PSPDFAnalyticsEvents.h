//
//  PSPDFAnalyticsEvents.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnalytics.h"

#pragma mark - Analytics Event Names

/**
 Prefix used for all analytics events. "pspdf".
 A underscore (`_`) is added after this prefix to all analytics events as well.
 */
PSPDF_EXPORT NSString *const PSPDFAnalyticsEventPrefix;

#pragma mark Document

/// Document load event. This event signifies that the user has loaded a document. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameDocumentLoad;
/// Page change event. This signifies that the user changed the page. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNamePageChange;

#pragma mark Annotation Creation

/// Enter annotation creation mode event. This event signifies that the user opened the annotation toolbar. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreationModeEnter;
/// Exit annotation creation mode event. This event signifies that the user closed the annotation toolbar. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreationModeExit;

#pragma mark Annotation Author

/// Show annotation creator dialog event. This signifies that the annotation creator dialog was shown to the user. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreatorDialogShow;
/// Cancel annotation creator dialog event. Signifies that the annotation creator dialog was cancelled by the user. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreatorDialogCancel;
/// Set annotation creator event. Signifies that the annotation creator dialog was confirmed by the user, setting a creator name. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreatorSet;

#pragma mark Annotation Editing

/**
 Select annotation event. This signifies that the user selected an annotation, either by tapping it or by any other option (for example using the annotation list).

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameAnnotationType`. Value: `PSPDFAnnotationString` of the selected annotation.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationSelect;
/**
 Create annotation event. This signifies that the user created an annotation and added it to the document.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameAnnotationType`. Value: `PSPDFAnnotationString` of the created annotation.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationCreate;
/**
 Delete annotation event. This signifies that the user deleted an annotation from the document.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameAnnotationType`. Value: `PSPDFAnnotationString` of the deleted annotation.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationDelete;

#pragma mark Annotation Inspector

/// Show annotation inspector event. This signifies that the user has opened the annotation inspector for editing annotation properties, either via the annotation toolbar or by editing an existing annotation. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameAnnotationInspectorShow;

#pragma mark Text Selection

/// Select text event. This signifies that the user has selected text on the document. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameTextSelect;

#pragma mark Outline

/// Open outline event. This signifies that the user opened the outline containing the document outline, annotations, and bookmarks. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameOutlineOpen;
/// Tap outline element in outline view event. This signifies that the user tapped an outline element in the outline view. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameOutlineElementSelect;
/**
 Tap annotation in outline view event. This signifies that the user tapped an annotation in the outline view.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameAnnotationType`. Value: `PSPDFAnnotationString` of the selected annotation.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameOutlineAnnotationSelect;

#pragma mark Thumbnail Grid

/// Open thumbnail grid event. This signifies that the user opened the thumbnail grid view. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameThumbnailGridOpen;

#pragma mark Document Editor

/// Open document editor event. This signifies that the user opened the document editor. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameDocumentEditorOpen;
/**
 Perform document editor action event. This signifies that the user performed an action inside the document editor.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameAction`. Value: `PSPDFAnalyticsEventAttributeValueAction` the user performed in the document editor (like `PSPDFAnalyticsEventAttributeValueActionInsertNewPage`)
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameDocumentEditorAction;

#pragma mark Bookmarks

/// Add bookmark event. This signifies that the user added a bookmark to the document. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkAdd;
/// Edit bookmarks event. This signifies that the user has entered bookmark editing mode inside the bookmark list. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkEdit;
/// Delete bookmark event. This signifies that the user has deleted a bookmark from the document. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkRemove;
/// Sort bookmark event. This signifies that the user changed moved the order of a bookmark item in the bookmark list. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkSort;
/// Rename bookmark event. This signifies that the user renamed a bookmark. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkRename;
/// Select bookmark event. This signigies that the user tapped a bookmark in the bookmark list. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameBookmarkSelect;

#pragma mark Search

/// Start search event. This signifies that the user started a search in the document by pressing the search icon (or any other way). No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameSearchStart;
/// Search result select event. This signifies that the user selected a search result after searching the document. No attributes.
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameSearchResultSelect;

#pragma mark Share

/**
 Share event. This signifies that the user has shared the document using the share sheet.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeNameActivityType`. Value: Activity type the user selected as string.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameShare;

#pragma mark Toolbar

/**
 Move toolbar event. This signifies that the toolbar was moved to a different location.

 Attributes:

 - Key: `PSPDFAnalyticsEventAttributeValueToolbarPosition`. Value: `PSPDFFlexibleToolbarPosition` of the destination.
 */
PSPDF_EXPORT PSPDFAnalyticsEventName const PSPDFAnalyticsEventNameToolbarMove;

#pragma mark - Analytics Event Attributes

PSPDF_EXPORT PSPDFAnalyticsEventAttributeName const PSPDFAnalyticsEventAttributeNameAnnotationType;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeName const PSPDFAnalyticsEventAttributeNameAction;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeName const PSPDFAnalyticsEventAttributeNameActivityType;

PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionInsertNewPage;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionRemoveSelectedPages;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionDuplicateSelectedPages;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionRotateSelectedPages;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionExportSelectedPages;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionSelectAllPages;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionUndo;
PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueActionRedo;

PSPDF_EXPORT PSPDFAnalyticsEventAttributeValue const PSPDFAnalyticsEventAttributeValueToolbarPosition;
