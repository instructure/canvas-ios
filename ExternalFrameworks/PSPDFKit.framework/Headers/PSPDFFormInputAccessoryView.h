//
//  PSPDFFormInputAccessoryView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFFormInputAccessoryViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// Notification when someone pressed "Clear Field".
PSPDF_EXPORT NSString *const PSPDFFormInputAccessoryViewDidPressClearButtonNotification;

/// Toolbar for Next|Previous controls for Form Elements.
PSPDF_CLASS_AVAILABLE @interface PSPDFFormInputAccessoryView : UIView

/// Display Done button. Defaults to YES.
@property (nonatomic) BOOL displayDoneButton;

/// Display Clear button. Defaults to YES.
@property (nonatomic) BOOL displayClearButton;

/// The input accessory delegate.
@property (nonatomic, weak) id<PSPDFFormInputAccessoryViewDelegate> delegate;

/// Trigger toolbar update.
- (void)updateToolbar;

@end


@interface PSPDFFormInputAccessoryView (SubclassingHooks)

/// Allow button customizations. Never return nil for these!
@property (nonatomic, readonly) UIBarButtonItem *nextButton;
@property (nonatomic, readonly) UIBarButtonItem *prevButton;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;
@property (nonatomic, readonly) UIBarButtonItem *clearButton;

- (IBAction)nextButtonPressed:(nullable id)sender;
- (IBAction)prevButtonPressed:(nullable id)sender;
- (IBAction)doneButtonPressed:(nullable id)sender;
- (IBAction)clearButtonPressed:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
