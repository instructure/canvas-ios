//
//  PSPDFStylusViewController.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"

@class PSPDFStylusManager, PSPDFStylusViewController;

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFStylusViewControllerDelegate <NSObject>

/// The driver class has been changed.
- (void)stylusViewControllerDidUpdateSelectedType:(PSPDFStylusViewController *)stylusViewController;

/// The settings button has been tapped.
- (void)stylusViewControllerDidTapSettingsButton:(PSPDFStylusViewController *)stylusViewController;

@end

/// Allows stylus management and type selection.
PSPDF_CLASS_AVAILABLE @interface PSPDFStylusViewController : PSPDFStaticTableViewController

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
/// `stylusManager` is required.
- (instancetype)initWithStylusManager:(PSPDFStylusManager *)stylusManager NS_DESIGNATED_INITIALIZER;

/// The currently selected driver class.
@property (nonatomic, nullable) Class selectedDriverClass;

/// The attached stylus manager. Can not be nil.
@property (nonatomic, readonly) PSPDFStylusManager *stylusManager;

/// The controller delegate.
@property (nonatomic, weak) id<PSPDFStylusViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
