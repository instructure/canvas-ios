//
//  PSPDFAnnotationGridViewController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFStyleable.h"
#import "PSPDFAnnotationSet.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAnnotationGridViewController, PSPDFAnnotationSetCell;

/// Delegate to be notified on signature actions.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationGridViewControllerDelegate <PSPDFOverridable>

@optional

/// Cancel button has been pressed.
/// @warning The popover can also disappear without any button pressed, in that case the delegate is not called.
- (void)annotationGridViewControllerDidCancel:(PSPDFAnnotationGridViewController *)annotationGridController;

/// Save/Done button has been pressed.
- (void)annotationGridViewController:(PSPDFAnnotationGridViewController *)annotationGridController didSelectAnnotationSet:(PSPDFAnnotationSet *)annotationSet;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationGridViewControllerDataSource <NSObject>

/// Returns number of sections.
- (NSInteger)numberOfSectionsInAnnotationGridViewController:(PSPDFAnnotationGridViewController *)annotationGridController;

/// Returns number of annotation sets per `section`.
- (NSInteger)annotationGridViewController:(PSPDFAnnotationGridViewController *)annotationGridController numberOfAnnotationsInSection:(NSInteger)section;

/// Returns the annotation set for `indexPath`.
- (PSPDFAnnotationSet *)annotationGridViewController:(PSPDFAnnotationGridViewController *)annotationGridController annotationSetForIndexPath:(NSIndexPath *)indexPath;

@end


/// Allows saving/loading of stored annotations.
/// Annotations are stored securely in the keychain.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationGridViewController : PSPDFBaseViewController <PSPDFStyleable>

/// Delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFAnnotationGridViewControllerDelegate> delegate;

/// Data Source.
@property (nonatomic, weak) IBOutlet id<PSPDFAnnotationGridViewControllerDataSource> dataSource;

/// Reloads from the dataSource.
- (void)reloadData;

@end

@interface PSPDFAnnotationGridViewController (SubclassingHooks) <UICollectionViewDelegate, UICollectionViewDataSource>

/// To make custom buttons.
- (void)close:(nullable id)sender;

/// Customize cell configuration.
- (void)configureCell:(PSPDFAnnotationSetCell *)annotationSetCell forIndexPath:(NSIndexPath *)indexPath;

/// Internally used collection view.
@property (nonatomic, readonly, nullable) UICollectionView *collectionView;

/// Trigger popover size recalculation.
- (void)updatePopoverSize;

@end

NS_ASSUME_NONNULL_END
