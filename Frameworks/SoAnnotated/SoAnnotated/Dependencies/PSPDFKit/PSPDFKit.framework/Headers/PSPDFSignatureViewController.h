//
//  PSPDFSignatureViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStyleable.h"
#import "PSPDFBaseViewController.h"
#import "PSPDFDrawView.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDrawView, PSPDFSignatureViewController, PSPDFColorButton;

/// Delegate to be notified on signature actions.
PSPDF_AVAILABLE_DECL @protocol PSPDFSignatureViewControllerDelegate <PSPDFOverridable>

@optional

/// Cancel button has been pressed.
- (void)signatureViewControllerDidCancel:(PSPDFSignatureViewController *)signatureController;

/// Save/Done button has been pressed.
- (void)signatureViewControllerDidSave:(PSPDFSignatureViewController *)signatureController;

@end

/// Allows adding signatures or drawings as ink annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFSignatureViewController : PSPDFBaseViewController <PSPDFStyleable>

/// Lines (arrays of boxed `PSPDFPoint`s) of the `drawView`.
/// @note Lines are in view coordinate space. To save them into PDF, first convert them to PDF coordinates
/// @see `PSPDFConvertViewLinesToPDFLines` for converting the points.
@property (nonatomic, readonly) NSArray<NSArray<NSValue *> *> *lines;

/// Enable natural drawing.
@property (nonatomic) BOOL naturalDrawingEnabled;

/// Color options for the color picker (limit this to about 3 `UIColor` instances).
/// Defaults to black, blue and red.
@property (nonatomic, copy) NSArray<UIColor *> *menuColors;

/// Signature controller delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFSignatureViewControllerDelegate> delegate;

/// @name Styling

/// Keeps the drawing area aspect ration regardless of the interface orientation.
/// Setting this to `NO` might produce unexpected results if the view bounds change.
/// Defaults to YES, except if the view is presented inside a form sheet on iPad.
@property (nonatomic) BOOL keepLandscapeAspectRatio;

@end

@interface PSPDFSignatureViewController (SubclassingHooks)

/// Internally used draw view. Use `lines` as a shortcut to get the drawn signature lines.
@property (nonatomic, readonly) PSPDFDrawView *drawView;

/// @name Actions for custom buttons.
- (void)cancel:(nullable id)sender;
- (void)done:(nullable id)sender;
- (void)clear:(nullable id)sender;
- (void)color:(PSPDFColorButton *)sender;

/// Customize the created color menu buttons.
- (PSPDFColorButton *)colorButtonForColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END

