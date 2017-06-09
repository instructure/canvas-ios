//
//  PSPDFControlDelegate.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFConfiguration.h"
#import "PSPDFEnvironment.h"
#import "PSPDFErrorHandler.h"
#import "PSPDFPresentationActions.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAction, PSPDFDocumentActionExecutor;

/// Protocol for handling page changes.
PSPDF_AVAILABLE_DECL @protocol PSPDFPageControls<NSObject>


/**
 Set the page to a specific page index.

 @param pageIndex Page index of the page that should be shown.
 @param animated Defines if changing the page should be animated.
 @return Returns `YES` if it succeeded. `NO` if it didn't.
 */
- (BOOL)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;

/**
 Set the page to a specific page index.

 @param pageIndex Page index of the page that should be shown.
 @param options An optional dictionary with options.
 @param animated Defines if changing the page should be animated.
 @return Returns `YES` if it succeeded. `NO` if it didn't.
 */
- (BOOL)setPageIndex:(NSUInteger)pageIndex options:(nullable NSDictionary<NSString *, NSNumber *> *)options animated:(BOOL)animated;

/**
 Scroll to the next page.

 @param animated Defines if changing the page should be animated.
 @return Returns `YES` if it succeeded. `NO` if it didn't.
 */
- (BOOL)scrollToNextPageAnimated:(BOOL)animated;

/**
 Scroll to the previous page.

 @param animated Defines if changing the page should be animated.
 @return Returns `YES` if it succeeded. `NO` if it didn't.
 */
- (BOOL)scrollToPreviousPageAnimated:(BOOL)animated;

/**
 Set the view mode.

 @param viewMode View mode to change to.
 @param animated Defines if changing the view mode should be animated.
 */
- (void)setViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated;

/// Execute an action.
- (BOOL)executePDFAction:(nullable PSPDFAction *)action targetRect:(CGRect)targetRect pageIndex:(NSUInteger)pageIndex animated:(BOOL)animated actionContainer:(nullable id)actionContainer;

/// Search for a specific string.
- (void)searchForString:(nullable NSString *)searchText options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated;

/// Document action executer responsible for handling actions.
@property (nonatomic, readonly) PSPDFDocumentActionExecutor *documentActionExecutor;

/// Presents the document info view controller.
- (nullable UIViewController *)presentDocumentInfoViewControllerWithOptions:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Allows file preview using QuickLook.
- (void)presentPreviewControllerForURL:(NSURL *)fileURL title:(nullable NSString *)title options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Reloads the displayed controller and view.
- (void)reloadData;

@end

/// Protocol handling the HUD.
PSPDF_AVAILABLE_DECL @protocol PSPDFHUDControls<NSObject>

/// Defines if the HUD should be shown.
@property (nonatomic, readonly) BOOL shouldShowControls;

/// Hides the HUD.
- (BOOL)hideControlsAnimated:(BOOL)animated;

/// Hides the HUD in response to a scroll action/
- (BOOL)hideControlsForUserScrollActionAnimated:(BOOL)animated;

/// Hidse the HUD and additional elements like page selection.
- (BOOL)hideControlsAndPageElementsAnimated:(BOOL)animated;

/// Toggles the visibility state of the HUD.
- (BOOL)toggleControlsAnimated:(BOOL)animated;

/// Shows the HUD.
- (BOOL)showControlsAnimated:(BOOL)animated;

/// Shows a menu if something (e.g. an annotation) is selected.
- (void)showMenuIfSelectedAnimated:(BOOL)animated allowPopovers:(BOOL)allowPopovers;

@end

/// Protocol handling various controls.
PSPDF_AVAILABLE_DECL @protocol PSPDFControlDelegate<PSPDFPresentationActions, PSPDFPageControls, PSPDFHUDControls, PSPDFErrorHandler>
@end

NS_ASSUME_NONNULL_END
