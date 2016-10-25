//
//  PSPDFContainerViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFStyleable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFContainerViewController;

PSPDF_AVAILABLE_DECL @protocol PSPDFContainerViewControllerDelegate <NSObject>

@optional

/// Called every time the index is changed.
- (void)containerViewController:(PSPDFContainerViewController *)controller didUpdateSelectedIndex:(NSUInteger)selectedIndex;

@end

/// Can embed other view controllers and transition between them.
PSPDF_CLASS_AVAILABLE @interface PSPDFContainerViewController : PSPDFBaseViewController <PSPDFStyleable>

/// Convenience initializer.
- (instancetype)initWithControllers:(nullable NSArray<__kindof UIViewController *> *)controllers titles:(nullable NSArray<NSString *> *)titles;

/// The container controller delegate, notifies when the index changes.
@property (nonatomic, weak) IBOutlet id<PSPDFContainerViewControllerDelegate> delegate;

/// @name View Controller adding/removing

/// Add view controller to the list.
/// @note Uses the default controller title.
- (void)addViewController:(UIViewController *)controller;

/// Remove view controller from the list.
- (void)removeViewController:(UIViewController *)controller;

/// All added view controllers.
@property (nonatomic, copy, readonly) NSArray<__kindof UIViewController *> *viewControllers;

/// @name State

/// The currently visible view controller index.
@property (nonatomic) NSUInteger visibleViewControllerIndex;

/// Set the currently visible view controller index.
- (void)setVisibleViewControllerIndex:(NSUInteger)visibleViewControllerIndex animated:(BOOL)animated;

/// @name Settings

/// Set to YES if you want to animate controller changes. Defaults to NO.
@property (nonatomic) BOOL shouldAnimateChanges;

@end

@interface PSPDFContainerViewController (SubclassingHooks)

/// Internally used segment.
@property (nonatomic, readonly, nullable) UISegmentedControl *filterSegment;

@end

NS_ASSUME_NONNULL_END
