//
//  PSPDFKit.h
//  PSPDFKit
//
//  Copyright © 2010-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#if !__has_feature(objc_arc)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-no-attribute"
#endif

// @category: Model
#import "PSPDFModelUmbrella.h"

// @category: Common
#import "PSPDFApplication.h"
#import "PSPDFConfiguration.h"
#import "PSPDFControlDelegate.h"
#import "PSPDFErrorHandler.h"
#import "PSPDFExternalURLHandler.h"
#import "PSPDFKit+PSPDFUI.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFSelectionState.h"
#import "PSPDFViewState.h"

// @category: Controllers
#import "PSPDFActivityViewController.h"
#import "PSPDFAnnotationGridViewController.h"
#import "PSPDFAnnotationStyleViewController.h"
#import "PSPDFAnnotationTableViewController.h"
#import "PSPDFBaseTableViewController.h"
#import "PSPDFBaseViewController.h"
#import "PSPDFBrightnessViewController.h"
#import "PSPDFContainerViewController.h"
#import "PSPDFDocumentSharingCoordinator.h"
#import "PSPDFDocumentSharingViewController.h"
#import "PSPDFFontPickerViewController.h"
#import "PSPDFImagePickerController.h"
#import "PSPDFMultiDocumentViewController.h"
#import "PSPDFNavigationController.h"
#import "PSPDFNoteAnnotationViewController.h"
#import "PSPDFPageGrabberController.h"
#import "PSPDFPageScrollViewController.h"
#import "PSPDFSavedAnnotationsViewController.h"
#import "PSPDFScreenController.h"
#import "PSPDFSettingsViewController.h"
#import "PSPDFSignatureSelectorViewController.h"
#import "PSPDFSignatureViewController.h"
#import "PSPDFSoundAnnotationController.h"
#import "PSPDFStampViewController.h"
#import "PSPDFStatefulTableViewController.h"
#import "PSPDFStatefulViewControllerProtocol.h"
#import "PSPDFStaticTableViewController.h"
#import "PSPDFTextStampViewController.h"
#import "PSPDFViewController.h"
#import "PSPDFViewControllerDelegate.h"
#import "PSPDFWebViewController.h"

// @category: Main Views
#import "PSPDFBackForwardButton.h"
#import "PSPDFContentScrollView.h"
#import "PSPDFHUDView.h"
#import "PSPDFMediaPlayerCoverView.h"
#import "PSPDFPageLabelView.h"
#import "PSPDFPageView+AnnotationMenu.h"
#import "PSPDFPageView.h"
#import "PSPDFRelayTouchesView.h"
#import "PSPDFScrollView.h"
#import "PSPDFTextSelectionView.h"

// @category: Annotations
#import "PSPDFAnnotationCell.h"
#import "PSPDFAnnotationSetCell.h"
#import "PSPDFAnnotationSetsCell.h"
#import "PSPDFAnnotationStateManager.h"
#import "PSPDFAnnotationStyle.h"
#import "PSPDFAnnotationView.h"
#import "PSPDFAnnotationViewProtocol.h"
#import "PSPDFColorButton.h"
#import "PSPDFDrawView.h"
#import "PSPDFEraseOverlay.h"
#import "PSPDFFormElementView.h"
#import "PSPDFFormInputAccessoryView.h"
#import "PSPDFFormInputAccessoryViewDelegate.h"
#import "PSPDFFreeTextAccessoryView.h"
#import "PSPDFFreeTextAnnotationView.h"
#import "PSPDFHostingAnnotationView.h"
#import "PSPDFLinkAnnotationBaseView.h"
#import "PSPDFLinkAnnotationView.h"
#import "PSPDFNoteAnnotationView.h"
#import "PSPDFSelectionView.h"
#import "PSPDFSignatureCell.h"
#import "PSPDFSignatureStore.h"

// @category: Forms
#import "PSPDFButtonFormElementView.h"
#import "PSPDFChoiceFormElementView.h"
#import "PSPDFFormRequest.h"
#import "PSPDFFormSubmissionDelegate.h"
#import "PSPDFTextFieldFormElementView.h"

// @category: Search
#import "PSPDFInlineSearchManager.h"
#import "PSPDFSearchHighlightView.h"
#import "PSPDFSearchHighlightViewManager.h"
#import "PSPDFSearchViewController.h"
#import "UISearchController+PSPDFKitAdditions.h"

// @category: Full-Text Search
#import "PSPDFDocumentPickerCell.h"
#import "PSPDFDocumentPickerController.h"
#import "PSPDFDocumentPickerIndexStatusCell.h"

// @category: View Modes
#import "PSPDFControllerState.h"
#import "PSPDFViewModePresenter.h"

// @category: Thumbnails
#import "PSPDFCollectionReusableFilterView.h"
#import "PSPDFPageCell.h"
#import "PSPDFPageGrabber.h"
#import "PSPDFScrubberBar.h"
#import "PSPDFThumbnailBar.h"
#import "PSPDFThumbnailGridViewCell.h"
#import "PSPDFThumbnailViewController.h"

// @category: Document Editor
#import "PSPDFDocumentEditor.h"
#import "PSPDFDocumentEditorCell.h"
#import "PSPDFDocumentEditorToolbar.h"
#import "PSPDFDocumentEditorToolbarController.h"
#import "PSPDFDocumentEditorViewController.h"
#import "PSPDFEditingChange.h"
#import "PSPDFNewPageViewController.h"
#import "PSPDFSaveViewController.h"

// @category: Outline
#import "PSPDFOutlineCell.h"
#import "PSPDFOutlineViewController.h"

// @category: Tabbed Bar
#import "PSPDFMultiDocumentListController.h"
#import "PSPDFTabbedBar.h"
#import "PSPDFTabbedViewController.h"

// @category: Embedded Files
#import "PSPDFEmbeddedFileCell.h"
#import "PSPDFEmbeddedFilesViewController.h"
#import "PSPDFViewController+EmbeddedFileSupport.h"

// @category: Bookmarks
#import "PSPDFBookmarkCell.h"
#import "PSPDFBookmarkIndicatorButton.h"
#import "PSPDFBookmarkViewController.h"

// @category: Toolbar
#import "PSPDFAnnotationGroupItem+PSPDFPresets.h"
#import "PSPDFAnnotationToolbar.h"
#import "PSPDFAnnotationToolbarConfiguration.h"
#import "PSPDFAnnotationToolbarController.h"
#import "PSPDFFlexibleToolbar.h"
#import "PSPDFFlexibleToolbarContainer.h"
#import "PSPDFFlexibleToolbarController.h"
#import "PSPDFToolbar.h"
#import "PSPDFToolbarButton.h"

// @category: Action Coordinators
#import "PSPDFDocumentActionExecutor.h"
#import "PSPDFDocumentInfoCoordinator.h"
#import "PSPDFMailCoordinator.h"
#import "PSPDFMessageCoordinator.h"
#import "PSPDFOpenInCoordinator.h"
#import "PSPDFPrintConfiguration.h"
#import "PSPDFPrintCoordinator.h"

// @category: Helpers
#import "PSPDFAppearanceModeManager.h"
#import "PSPDFBrightnessManager.h"
#import "PSPDFColorPicker.h"
#import "PSPDFMenuItem.h"
#import "PSPDFNavigationItem.h"
#import "PSPDFNetworkActivityIndicatorManager.h"
#import "PSPDFSignatureValidator.h"
#import "PSPDFSpeechController.h"
#import "PSPDFStatusHUD.h"
#import "PSPDFStyleable.h"
#import "PSPDFThumbnailFlowLayout.h"
#import "PSPDFUsernameHelper.h"
#import "PSPDFVisiblePagesDataSource.h"

// @category: Signatures
#import "PSPDFSignedFormElementViewController.h"
#import "PSPDFUnsignedFormElementViewController.h"

// @category: Gallery
#import "PSPDFGalleryConfiguration.h"
#import "PSPDFGalleryContainerView.h"
#import "PSPDFGalleryContentCaptionView.h"
#import "PSPDFGalleryContentView.h"
#import "PSPDFGalleryContentViewProtocols.h"
#import "PSPDFGalleryImageContentView.h"
#import "PSPDFGalleryImageItem.h"
#import "PSPDFGalleryItem.h"
#import "PSPDFGalleryManifest.h"
#import "PSPDFGalleryUnknownItem.h"
#import "PSPDFGalleryVideoContentView.h"
#import "PSPDFGalleryVideoItem.h"
#import "PSPDFGalleryView.h"
#import "PSPDFGalleryViewController.h"
#import "PSPDFGalleryWebContentView.h"
#import "PSPDFGalleryWebItem.h"
#import "PSPDFIdentifiable.h"
#import "PSPDFMediaPlayerController.h"
#import "PSPDFMultimediaAnnotationView.h"
#import "PSPDFMultimediaViewController.h"
#import "PSPDFPresentationActions.h"
#import "PSPDFRemoteContentObject.h"

// @category: Stylus Support
#import "PSPDFApplePencilDriver.h"
#import "PSPDFStylusDriver.h"
#import "PSPDFStylusDriverDelegate.h"
#import "PSPDFStylusManager.h"
#import "PSPDFStylusTouch.h"
#import "PSPDFStylusViewController.h"

// @category: Assisting Views
#import "PSPDFAvoidingScrollView.h"
#import "PSPDFBlurView.h"
#import "PSPDFButton.h"
#import "PSPDFLabelView.h"
#import "PSPDFResizableView.h"
#import "PSPDFRoundedLabel.h"
#import "PSPDFSegmentedControl.h"
#import "PSPDFSelectableCollectionViewCell.h"
#import "PSPDFSpinnerCell.h"
#import "PSPDFTableViewCell.h"

// @category: Analytics
#import "PSPDFAnalytics.h"
#import "PSPDFAnalyticsEvents.h"
#import "PSPDFKit+Analytics.h"

#if !__has_feature(objc_arc)
#pragma clang diagnostic pop
#endif
