//
//  PSPDFStampViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationGridViewController.h"
#import "PSPDFStampAnnotation.h"
#import "PSPDFTextStampViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFStampViewController, PSPDFStampAnnotation;

/// Allows adding signatures or drawings as ink annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFStampViewController : PSPDFAnnotationGridViewController <PSPDFAnnotationGridViewControllerDataSource, PSPDFTextStampViewControllerDelegate>

/// Return default available set of stamp annotations.
+ (NSArray<PSPDFStampAnnotation *> *)defaultStampAnnotations;

/// Allows to set a different set of default annotations. Thread safe.
/// Setting `defaultStampAnnotations` will restore the default set of stamp annotations.
+ (void)setDefaultStampAnnotations:(nullable NSArray<PSPDFStampAnnotation *> *)defaultStampAnnotations;

/// Available stamp types. Set before showing controller.
@property (nonatomic, copy) NSArray<PSPDFStampAnnotation *> *stamps;

/// Adds a special stamp that forwards to an interface (`PSPDFTextStampViewController`) where custom stamps can be created.
/// Defaults to YES.
/// @warning Changing this will reset the `stamps` array.
@property (nonatomic) BOOL customStampEnabled;

/// Adds date stamps. They are recreated every time the `PSPDFStampViewController` is created
/// to present the current date and thus not a part of the `defaultStampAnnotations` array.
/// Defaults to YES.
/// @warning Changing this will reset the `stamps` array.
@property (nonatomic) BOOL dateStampsEnabled;

@end

@interface PSPDFStampViewController (SubclassingHooks)

/// Creates the default date fonts - Revised and Rejected.
- (NSArray<PSPDFStampAnnotation *> *)defaultDateStamps;

@end

NS_ASSUME_NONNULL_END
