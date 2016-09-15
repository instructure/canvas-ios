//
//  PSPDFStatusHUD.h
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

NS_ASSUME_NONNULL_BEGIN

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

/// Represents a single HUD item.
/// @warning Only use this class on the main thread.
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

+ (instancetype)progressWithText:(nullable NSString *)text;
+ (instancetype)indeterminateProgressWithText:(nullable NSString *)text;
+ (instancetype)successWithText:(nullable NSString *)text;
+ (instancetype)errorWithText:(nullable NSString *)text;
+ (instancetype)itemWithText:(nullable NSString *)text image:(nullable UIImage *)image;

- (void)setHUDStyle:(PSPDFStatusHUDStyle)style;

/// Show the HUD item.
- (void)pushAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Show the HUD item and schedule a dismissal time.
- (void)pushAndPopWithDelay:(NSTimeInterval)interval animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// Hide HID item.
- (void)popAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

/// A globally usable progress view/status HUD.
PSPDF_CLASS_AVAILABLE @interface PSPDFStatusHUD : NSObject

+ (NSArray<PSPDFStatusHUDItem *> *)items;
+ (void)popAllItemsAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFStatusHUDView : UIView
@property (nonatomic, nullable) PSPDFStatusHUDItem *item;
@end

NS_ASSUME_NONNULL_END
