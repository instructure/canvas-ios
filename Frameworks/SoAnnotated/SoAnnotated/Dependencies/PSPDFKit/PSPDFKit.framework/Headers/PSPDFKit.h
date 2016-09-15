//
//  PSPDFKit.h
//  PSPDFKit
//
//  Copyright (c) 2010-2016 PSPDFKit GmbH. All rights reserved.
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
#import "PSPDFViewState.h"
#import "PSPDFKit+PSPDFUI.h"
#import "PSPDFPresentationContext.h"

// @category: Controllers
#import "PSPDFViewController.h"
#import "PSPDFViewControllerDelegate.h"
#import "PSPDFPageScrollViewController.h"
#import "PSPDFMultiDocumentViewController.h"
#import "PSPDFBrightnessViewController.h"
#import "PSPDFStampViewController.h"
#import "PSPDFSignatureViewController.h"
#import "PSPDFFontPickerViewController.h"
#import "PSPDFNoteAnnotationViewController.h"
#import "PSPDFAnnotationTableViewController.h"
#import "PSPDFSavedAnnotationsViewController.h"
#import "PSPDFContainerViewController.h"
#import "PSPDFWebViewController.h"
#import "PSPDFSoundAnnotationController.h"
#import "PSPDFNavigationController.h"
#import "PSPDFImagePickerController.h"
#import "PSPDFSignatureSelectorViewController.h"
#import "PSPDFDocumentSharingViewController.h"
#import "PSPDFAnnotationStyleViewController.h"
#import "PSPDFTextStampViewController.h"
#import "PSPDFStatefulTableViewController.h"
#import "PSPDFDocumentSharingCoordinator.h"
#import "PSPDFAnnotationGridViewController.h"
#import "PSPDFStaticTableViewController.h"
#import "PSPDFBaseTableViewController.h"
#import "PSPDFBaseViewController.h"
#import "PSPDFSettingsViewController.h"

// @category: Main Views
#import "PSPDFPageView.h"
#import "PSPDFPageView+AnnotationMenu.h"
#import "PSPDFContentScrollView.h"
#import "PSPDFPageLabelView.h"
#import "PSPDFBackForwardButton.h"
#import "PSPDFHUDView.h"
#import "PSPDFScrollView.h"
#import "PSPDFTextSelectionView.h"
#import "PSPDFMediaPlayerCoverView.h"
#import "PSPDFRelayTouchesView.h"

// @category: Annotations
#import "PSPDFAnnotationStateManager.h"
#import "PSPDFAnnotationCell.h"
#import "PSPDFAnnotationSetCell.h"
#import "PSPDFAnnotationViewProtocol.h"
#import "PSPDFLinkAnnotationView.h"
#import "PSPDFNoteAnnotationView.h"
#import "PSPDFFreeTextAnnotationView.h"
#import "PSPDFFreeTextAccessoryView.h"
#import "PSPDFSelectionView.h"
#import "PSPDFDrawView.h"
#import "PSPDFEraseOverlay.h"
#import "PSPDFSignatureCell.h"
#import "PSPDFSignatureStore.h"
#import "PSPDFAnnotationSetsCell.h"
#import "PSPDFColorButton.h"
#import "PSPDFAnnotationView.h"
#import "PSPDFLinkAnnotationBaseView.h"
#import "PSPDFAnnotationStyle.h"
#import "PSPDFHostingAnnotationView.h"
#import "PSPDFFormElementView.h"
#import "PSPDFFormInputAccessoryView.h"
#import "PSPDFFormInputAccessoryViewDelegate.h"

// @category: Forms
#import "PSPDFFormRequest.h"
#import "PSPDFFormSubmissionDelegate.h"
#import "PSPDFChoiceFormElementView.h"
#import "PSPDFButtonFormElementView.h"
#import "PSPDFTextFieldFormElementView.h"

// @category: Search
#import "PSPDFSearchHighlightViewManager.h"
#import "PSPDFSearchViewController.h"
#import "PSPDFSearchResultCell.h"
#import "PSPDFSearchStatusCell.h"
#import "PSPDFSearchHighlightView.h"
#import "PSPDFInlineSearchManager.h"
#import "UISearchController+PSPDFKitAdditions.h"

// @category: Full-text Search
#import "PSPDFDocumentPickerController.h"
#import "PSPDFDocumentPickerCell.h"
#import "PSPDFDocumentPickerIndexStatusCell.h"

// @category: View modes
#import "PSPDFViewModePresenter.h"
#import "PSPDFControllerState.h"

// @category: Thumbnails
#import "PSPDFCollectionReusableFilterView.h"
#import "PSPDFThumbnailViewController.h"
#import "PSPDFPageCell.h"
#import "PSPDFThumbnailGridViewCell.h"
#import "PSPDFScrubberBar.h"
#import "PSPDFThumbnailBar.h"

// @category: Document editor
#import "PSPDFDocumentEditor.h"
#import "PSPDFEditingChange.h"
#import "PSPDFDocumentEditorViewController.h"
#import "PSPDFDocumentEditorToolbarController.h"
#import "PSPDFDocumentEditorToolbar.h"
#import "PSPDFDocumentEditorCell.h"
#import "PSPDFNewPageViewController.h"
#import "PSPDFSaveViewController.h"

// @category: Outline
#import "PSPDFOutlineViewController.h"
#import "PSPDFOutlineCell.h"

// @category: Tabbed Bar
#import "PSPDFTabbedBar.h"
#import "PSPDFTabbedViewController.h"
#import "PSPDFMultiDocumentListController.h"

// @category: Embedded Files
#import "PSPDFEmbeddedFilesViewController.h"
#import "PSPDFEmbeddedFileCell.h"
#import "PSPDFViewController+EmbeddedFileSupport.h"

// @category: Bookmarks
#import "PSPDFBookmarkViewController.h"
#import "PSPDFBookmarkCell.h"

// @category: Toolbar
#import "PSPDFFlexibleToolbar.h"
#import "PSPDFFlexibleToolbarController.h"
#import "PSPDFToolbar.h"
#import "PSPDFToolbarButton.h"
#import "PSPDFAnnotationToolbar.h"
#import "PSPDFFlexibleToolbarContainer.h"
#import "PSPDFAnnotationToolbarController.h"
#import "PSPDFAnnotationToolbarConfiguration.h"
#import "PSPDFAnnotationGroupItem+PSPDFPresets.h"

// @category: Action Coordinators
#import "PSPDFPrintCoordinator.h"
#import "PSPDFMailCoordinator.h"
#import "PSPDFMessageCoordinator.h"
#import "PSPDFOpenInCoordinator.h"
#import "PSPDFDocumentActionExecutor.h"
#import "PSPDFDocumentInfoCoordinator.h"

// @category: Helpers
#import "PSPDFMenuItem.h"
#import "PSPDFStatusHUD.h"
#import "PSPDFSpeechController.h"
#import "PSPDFThumbnailFlowLayout.h"
#import "PSPDFNetworkActivityIndicatorManager.h"
#import "PSPDFSignatureValidator.h"
#import "PSPDFUsernameHelper.h"
#import "PSPDFStyleable.h"
#import "PSPDFVisiblePagesDataSource.h"
#import "PSPDFAppearanceModeManager.h"
#import "PSPDFBrightnessManager.h"
#import "PSPDFNavigationItem.h"
#import "PSPDFColorPicker.h"

// @category: Signatures
#import "PSPDFSignedFormElementViewController.h"
#import "PSPDFUnsignedFormElementViewController.h"

// @category: Gallery
#import "PSPDFGalleryConfiguration.h"
#import "PSPDFGalleryView.h"
#import "PSPDFGalleryViewController.h"
#import "PSPDFGalleryContentViewProtocols.h"
#import "PSPDFGalleryContentView.h"
#import "PSPDFGalleryImageContentView.h"
#import "PSPDFGalleryVideoContentView.h"
#import "PSPDFGalleryWebContentView.h"
#import "PSPDFGalleryContentCaptionView.h"
#import "PSPDFMultimediaAnnotationView.h"
#import "PSPDFGalleryContainerView.h"
#import "PSPDFGalleryManifest.h"
#import "PSPDFGalleryVideoItem.h"
#import "PSPDFGalleryImageItem.h"
#import "PSPDFGalleryUnknownItem.h"
#import "PSPDFGalleryWebItem.h"
#import "PSPDFMediaPlayerController.h"
#import "PSPDFRemoteContentObject.h"
#import "PSPDFMultimediaViewController.h"
#import "PSPDFPresentationActions.h"
#import "PSPDFGalleryItem.h"
#import "PSPDFIdentifiable.h"

// @category: Stylus Support
#import "PSPDFStylusManager.h"
#import "PSPDFStylusTouch.h"
#import "PSPDFStylusViewController.h"
#import "PSPDFStylusDriver.h"
#import "PSPDFStylusDriverDelegate.h"
#import "PSPDFAnnotationStateManager+StylusSupport.h"

// @category: Assisting Views
#import "PSPDFBlurView.h"
#import "PSPDFButton.h"
#import "PSPDFLabelView.h"
#import "PSPDFSegmentedControl.h"
#import "PSPDFRoundedLabel.h"
#import "PSPDFSpinnerCell.h"
#import "PSPDFAvoidingScrollView.h"
#import "PSPDFResizableView.h"
#import "PSPDFSelectableCollectionViewCell.h"
#import "PSPDFTableViewCell.h"

#if !__has_feature(objc_arc)
#pragma clang diagnostic pop
#endif
