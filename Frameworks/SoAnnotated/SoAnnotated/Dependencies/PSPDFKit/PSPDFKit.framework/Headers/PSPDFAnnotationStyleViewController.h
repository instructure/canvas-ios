//
//  PSPDFAnnotationStyleViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFontPickerViewController.h"
#import "PSPDFStaticTableViewController.h"
#import "PSPDFStyleable.h"
#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_EXPORT NSString *const PSPDFConvertFreeTextAnnotationCalloutActionKey;

@class PSPDFAnnotationStyleViewController, PSPDFAnnotation;
@protocol PSPDFAnnotationViewProtocol;

/// Delegate for `PSPDFAnnotationStyleViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationStyleViewControllerDelegate <PSPDFOverridable>

/// Called whenever one or more style properties of `PSPDFAnnotationStyleViewController` change.
- (void)annotationStyleController:(PSPDFAnnotationStyleViewController *)styleController didChangeProperties:(NSArray<NSString *> *)propertyNames;

@optional

/// Called when a user starts changing a property (e.g. touch down on the slider)
/// @warning There might not be a call to `didChangeProperty:` if the user doesn't actually change the value (just touches it)
/// @note Will not be fired for all properties.
- (void)annotationStyleController:(PSPDFAnnotationStyleViewController *)styleController willStartChangingProperty:(NSString *)propertyName;

/// Called when a user finishes changing a property (e.g. slider touch up)
/// @note Will not be fired for all properties.
- (void)annotationStyleController:(PSPDFAnnotationStyleViewController *)styleController didEndChangingProperty:(NSString *)propertyName;

/// Should return the annotation view that currently represents the provided `annotation`, if available.
/// Important for free text annotation sizing.
- (nullable UIView <PSPDFAnnotationViewProtocol> *)annotationStyleController:(PSPDFAnnotationStyleViewController *)styleController annotationViewForAnnotation:(PSPDFAnnotation *)annotation;

@end

/// Allows to set/change the style of an annotation.
/// @note: The inspector currently only supports setting *one* annotation, but since long-term we want multi-select-change, the API has already been prepared for.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationStyleViewController : PSPDFStaticTableViewController <PSPDFFontPickerViewControllerDelegate, PSPDFStyleable>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
/// Initialize the controller with one or multiple annotations.
- (instancetype)initWithAnnotations:(nullable NSArray<PSPDFAnnotation *> *)annotations NS_DESIGNATED_INITIALIZER;

/// The current selected annotations.
@property (nonatomic, copy, nullable) NSArray<PSPDFAnnotation *> *annotations;

/// Controller delegate. Informs about begin/end editing a property.
@property (nonatomic, weak) IBOutlet id<PSPDFAnnotationStyleViewControllerDelegate> delegate;

/// Shows a preview area on top. Defaults to NO.
@property (nonatomic) BOOL showPreviewArea;

/// @name Customization

/// List of supported inspector properties for various annotation types
/// Dictionary in format annotation type string : array of arrays of property strings (`NSArray<NSArray<NSString *> *> *`) OR a block that returns this and takes `annotations` as argument (`NSArray<NSArray<NSString *> *> *(^block)(PSPDFAnnotation *annotation)`).
/// Defaults to an empty dictionary. Normally set to the values from PSPDFConfiguration after initialization.
@property (nonatomic, copy) NSDictionary<NSString *, id> *propertiesForAnnotations;

/// Shows a custom cell with configurable color presets for the provided annotation types.
/// Defaults to PSPDFAnnotationTypeAll. Normally set to the values from PSPDFConfiguration after initialization.
@property (nonatomic) PSPDFAnnotationType typesShowingColorPresets;

/// Saves changes to the color presets. Defaults to YES.
@property (nonatomic) BOOL persistsColorPresetChanges;

@end


@interface PSPDFAnnotationStyleViewController (SubclassingHooks)

/// Returns the list of properties where we want to build cells for.
/// @note The arrays can be used to split the properties into different sections.
- (NSArray<NSArray<NSString *> *> *)propertiesForAnnotations:(NSArray<PSPDFAnnotation *> *)annotations;

@end

NS_ASSUME_NONNULL_END
