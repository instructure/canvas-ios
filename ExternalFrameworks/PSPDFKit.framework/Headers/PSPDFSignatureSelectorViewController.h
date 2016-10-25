//
//  PSPDFSignatureSelectorViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"
#import "PSPDFStyleable.h"
#import "PSPDFStatefulTableViewController.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSignatureSelectorViewController, PSPDFInkAnnotation;
@protocol PSPDFSignatureStore;

/// Delegate to be notified when the `PSPDFSignatureSelectorViewController` has a valid selection.
PSPDF_AVAILABLE_DECL @protocol PSPDFSignatureSelectorViewControllerDelegate <PSPDFOverridable>

/// A signature has been selected.
- (void)signatureSelectorViewController:(PSPDFSignatureSelectorViewController *)signatureSelectorController didSelectSignature:(PSPDFInkAnnotation *)signature;

/// The 'add' button has been pressed.
- (void)signatureSelectorViewControllerWillCreateNewSignature:(PSPDFSignatureSelectorViewController *)signatureSelectorController;

@end

/// Shows a list of signatures to select one.
/// Will show up in landscape via `preferredInterfaceOrientationForPresentation`.
PSPDF_CLASS_AVAILABLE @interface PSPDFSignatureSelectorViewController : PSPDFStatefulTableViewController <PSPDFStyleable>

/// Signature store with signatures that are being displayed.
@property (nonatomic, nullable) id<PSPDFSignatureStore> signatureStore;

/// Signature selector delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFSignatureSelectorViewControllerDelegate> delegate;

@end

@interface PSPDFSignatureSelectorViewController (SubclassingHooks)

/// Button that will allow adding a new signature.
/// @note The toolbar will be set up in `viewWillAppear:`.
@property (nonatomic, readonly) UIBarButtonItem *addSignatureButtonItem;

/// A button that will dismiss the view controller, shown in the navigation bar except when in a popover.
@property (nonatomic, readonly) UIBarButtonItem *doneButtonItem;

/// @name Actions
- (void)doneAction:(nullable id)sender;
- (void)addSignatureAction:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
