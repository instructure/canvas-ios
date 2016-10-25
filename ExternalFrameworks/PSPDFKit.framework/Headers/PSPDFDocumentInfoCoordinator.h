//
//  PSPDFDocumentInfoCoordinator.h
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
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument;
@protocol PSPDFPresentationActions;

/// The outline (Table of Contents) controller.
PSPDF_EXPORT NSString *const PSPDFDocumentInfoOptionOutline;

/// Bookmark list controller.
PSPDF_EXPORT NSString *const PSPDFDocumentInfoOptionBookmarks;

/// Annotation list controller. Requires `PSPDFFeatureMaskAnnotationEditing`.
PSPDF_EXPORT NSString *const PSPDFDocumentInfoOptionAnnotations;

/// Embedded Files. Requires `PSPDFFeatureMaskAnnotationEditing`.
PSPDF_EXPORT NSString *const PSPDFDocumentInfoOptionEmbeddedFiles;

/// Coordinates a common view controller for document metadata, such as outline, bookmarks or annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentInfoCoordinator : NSObject

/// Present view controller on `targetController`.
- (nullable UIViewController *)presentToViewController:(UIViewController <PSPDFPresentationActions> *)targetController options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Checks if there's data to present.
@property (nonatomic, getter=isAvailable, readonly) BOOL available;

/// The document attached to the document info coordinator.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Delegate to fetch subclasses.
@property (nonatomic, weak) id <PSPDFOverridable> delegate;

/// Choose the controller type.
/// Defaults to `PSPDFDocumentInfoOptionOutline, PSPDFDocumentInfoOptionAnnotations, PSPDFDocumentInfoOptionBookmarks, PSPDFDocumentInfoOptionEmbeddedFiles`.
/// @note Change this before the controller is being displayed.
@property (nonatomic, copy) NSArray<NSString *> *availableControllerOptions;

/// Called after a controller has been created. Set a block to allow custom modifications.
/// This sets the delegate of the controllers by default. If you set a custom block, ensure to call the previous implementation.
@property (nonatomic, copy, nullable) void (^didCreateControllerBlock)(UIViewController *controller, NSString *option);

@end

@interface PSPDFDocumentInfoCoordinator (SubclassingHooks)

/// Subclass to allow early controller customization.
- (nullable UIViewController *)controllerForOption:(NSString *)option;

/// Is used internally to filter unavailable options.
- (BOOL)isOptionAvailable:(NSString *)option;

@end

NS_ASSUME_NONNULL_END
