//
//  PSPDFControlDelegate.h
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
#import "PSPDFConfiguration.h"
#import "PSPDFPresentationActions.h"
#import "PSPDFErrorHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAction, PSPDFDocumentActionExecutor;

PSPDF_AVAILABLE_DECL @protocol PSPDFPageControls <NSObject>

- (BOOL)setPage:(NSUInteger)page animated:(BOOL)animated;
- (BOOL)setPage:(NSUInteger)page options:(nullable NSDictionary<NSString *, NSNumber *> *)options animated:(BOOL)animated;
- (BOOL)scrollToNextPageAnimated:(BOOL)animated;
- (BOOL)scrollToPreviousPageAnimated:(BOOL)animated;

- (void)setViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated;

// Execute actions
- (BOOL)executePDFAction:(nullable PSPDFAction *)action targetRect:(CGRect)targetRect page:(NSUInteger)page animated:(BOOL)animated actionContainer:(nullable id)actionContainer;
- (void)searchForString:(nullable NSString *)searchText options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated;

@property (nonatomic, readonly) PSPDFDocumentActionExecutor *documentActionExecutor;

- (nullable UIViewController *)presentDocumentInfoViewControllerWithOptions:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

- (void)presentPreviewControllerForURL:(NSURL *)fileURL title:(nullable NSString *)title options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

- (void)reloadData;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFHUDControls <NSObject>

- (BOOL)hideControlsAnimated:(BOOL)animated;
- (BOOL)hideControlsForUserScrollActionAnimated:(BOOL)animated;
- (BOOL)hideControlsAndPageElementsAnimated:(BOOL)animated;
- (BOOL)toggleControlsAnimated:(BOOL)animated;
@property (nonatomic, readonly) BOOL shouldShowControls;
- (BOOL)showControlsAnimated:(BOOL)animated;
- (void)showMenuIfSelectedAnimated:(BOOL)animated allowPopovers:(BOOL)allowPopovers;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFControlDelegate <PSPDFPresentationActions, PSPDFPageControls, PSPDFHUDControls, PSPDFErrorHandler>
@end

NS_ASSUME_NONNULL_END
