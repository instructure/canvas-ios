//
//  PSPDFTextStampViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFStampAnnotation, PSPDFTextStampViewController;

/// Delegate to be notified on signature actions.
PSPDF_AVAILABLE_DECL @protocol PSPDFTextStampViewControllerDelegate <PSPDFOverridable>

@optional

/// The 'Add' button has been pressed.
- (void)textStampViewController:(PSPDFTextStampViewController *)stampController didCreateAnnotation:(PSPDFStampAnnotation *)stampAnnotation;

@end

/// Allows to create/edit a custom text annotation stamp.
PSPDF_CLASS_AVAILABLE @interface PSPDFTextStampViewController : PSPDFStaticTableViewController

/// Initialize controller, optionally with a preexisting stamp.
- (instancetype)initWithStampAnnotation:(nullable PSPDFStampAnnotation *)stampAnnotation NS_DESIGNATED_INITIALIZER;

/// Text Stamp controller delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFTextStampViewControllerDelegate> delegate;

/// The stamp annotation.
/// If controller isn't initialize with a stamp, a new one will be created.
@property (nonatomic, readonly) PSPDFStampAnnotation *stampAnnotation;

/// The default stamp text if stamp is created. Defaults to nil.
@property (nonatomic, copy, nullable) NSString *defaultStampText;

@end

NS_ASSUME_NONNULL_END
