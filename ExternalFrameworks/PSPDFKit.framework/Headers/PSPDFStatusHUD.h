//
//  PSPDFStatusHUD.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// Defines the style of the status HUD.
typedef NS_ENUM(NSUInteger, PSPDFStatusHUDStyle) {
    /// User interactions enabled, no UI mask.
    PSPDFStatusHUDStyleNone = 0,
    /// User interactions disabled, clear UI mask.
    PSPDFStatusHUDStyleClear,
    /// User interactions disabled, black UI mask.
    PSPDFStatusHUDStyleBlack,
    /// User interactions disabled, gradient UI mask.
    PSPDFStatusHUDStyleGradient
} PSPDF_ENUM_AVAILABLE;

/**
 Represents a single HUD item.
 @warning Only use this class on the main thread.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFStatusHUDItem : NSObject

/// The title to display. Can be nil.
@property (nonatomic, copy, nullable) NSString *title;

/// The subtitle to display. Can be nil.
@property (nonatomic, copy, nullable) NSString *subtitle;

/// The main text to display. Can be nil.
@property (nonatomic, copy, nullable) NSString *text;

/// Set if we should show progress.
@property (nonatomic) CGFloat progress;

/// An attached view.
@property (nonatomic, nullable) UIView *view;

/**
 Creates a status HUD item with progress.

 @param text Text that should be shown on the HUD item.
 */
+ (instancetype)progressWithText:(nullable NSString *)text;

/**
 Creates a status HUD item with an indeterminate progress.

 @param text Text that should be shown on the HUD item.
 */
+ (instancetype)indeterminateProgressWithText:(nullable NSString *)text;

/**
 Creates a status HUD item with a success indicator.

 @param text Text that should be shown on the HUD item.
 */
+ (instancetype)successWithText:(nullable NSString *)text;

/**
 Creates a status HUD item with an error indicator.

 @param text Text that should be shown on the HUD item.
 */
+ (instancetype)errorWithText:(nullable NSString *)text;

/**
 Creates a status HUD item with a text and an image.

 @param text Text that should be shown on the HUD item.
 @param image Image that should be shown on the HUD item.
 */
+ (instancetype)itemWithText:(nullable NSString *)text image:(nullable UIImage *)image;

/// Change how the HUD should be styled.
- (void)setHUDStyle:(PSPDFStatusHUDStyle)style;

/// Show the HUD item.
- (void)pushAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Show the HUD item and schedule a dismissal time.
- (void)pushAndPopWithDelay:(NSTimeInterval)interval animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Hide the HUD item.
- (void)popAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

/// A globally usable progress view/status HUD.
PSPDF_CLASS_AVAILABLE @interface PSPDFStatusHUD : NSObject

/// All the status HUD items to be shown.
+ (NSArray<PSPDFStatusHUDItem *> *)items;

/// Hide all visible status HUD items, if any.
+ (void)popAllItemsAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

/// Status HUD view that represents a given status HUD item.
PSPDF_CLASS_AVAILABLE @interface PSPDFStatusHUDView : UIView

/// Status HUD item to be shown on the view.
@property (nonatomic, nullable) PSPDFStatusHUDItem *item;

@end

NS_ASSUME_NONNULL_END
