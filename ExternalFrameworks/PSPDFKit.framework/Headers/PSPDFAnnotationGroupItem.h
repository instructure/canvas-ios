//
//  PSPDFAnnotationGroupItem.h
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
#import "PSPDFModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAnnotationGroupItem;
typedef UIImage *_Nonnull(^PSPDFAnnotationGroupItemConfigurationBlock)(PSPDFAnnotationGroupItem *item, id _Nullable container, UIColor *tintColor);

PSPDF_EXPORT NSString *const PSPDFAnnotationStringInkVariantPen;
PSPDF_EXPORT NSString *const PSPDFAnnotationStringInkVariantHighlighter;
PSPDF_EXPORT NSString *const PSPDFAnnotationStringLineVariantArrow;
PSPDF_EXPORT NSString *const PSPDFAnnotationStringFreeTextVariantCallout;

/// Simple helper that combines a state + variant into a new identifier.
/// Can be used to set custom types in the `PSPDFStyleManager`.
PSPDF_EXPORT NSString *PSPDFAnnotationStateVariantIdentifier(NSString *_Nullable state, NSString * _Nullable variant);

/// An annotation group items defines one annotation type, optionally with a variant.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFAnnotationGroupItem : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Creates a group item with the specified annotation type.
/// @see itemWithType:variant:configurationBlock:
+ (instancetype)itemWithType:(NSString *)type;

/// Creates a group item with the specified annotation type and optional variant identifier.
/// @see itemWithType:variant:configurationBlock:
+ (instancetype)itemWithType:(NSString *)type variant:(nullable NSString *)variant;

/// Creates a group item with the specified annotation type, an optional variant identifier and configuration block.
/// @param type The annotation type. See `PSPDFAnnotation.h` for a list of valid types.
/// @param variant An optional string identifier for the item variant. Use variants to add several instances of the same tool with uniquely preservable annotation style settings.
/// @param block An option block, that should return the button's image. If nil, `defaultConfigurationBlock` is used.
/// @note Whenever possible try to return a template image from the configuration block (UIImageRenderingModeAlwaysTemplate). Use the provided tint color only when you need multi-color images.
+ (instancetype)itemWithType:(NSString *)type variant:(nullable NSString *)variant configurationBlock:(PSPDFAnnotationGroupItemConfigurationBlock)block;

/// A block that configures an preset image based on the annotation type.
/// This is the default configuration block.
+ (PSPDFAnnotationGroupItemConfigurationBlock)defaultConfigurationBlock;

/// The set annotation type. See `PSPDFAnnotation.h` for a list of valid types.
@property (nonatomic, copy, readonly) NSString *type;

/// The annotation variant, if set during initialization.
@property (nonatomic, copy, readonly, nullable) NSString *variant;

/// Used to generate the annotation image. Will be `defaultConfigurationBlock` or `inkConfigurationBlock` in most cases.
@property (nonatomic, copy, readonly) PSPDFAnnotationGroupItemConfigurationBlock configurationBlock;

@end

NS_ASSUME_NONNULL_END
