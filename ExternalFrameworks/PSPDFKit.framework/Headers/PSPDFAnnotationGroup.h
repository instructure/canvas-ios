//
//  PSPDFAnnotationGroup.h
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

@class PSPDFAnnotationGroupItem;

NS_ASSUME_NONNULL_BEGIN

/// Used to configure custom annotation groups for the annotation toolbar.
/// @see `PSPDFAnnotationToolbarConfiguration` for details.
///
/// @code
/// [[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:@[
///
/// [PSPDFAnnotationGroup groupWithItems:@[
/// [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringInk variant:PSPDFAnnotationStringInkVariantPen
/// configurationBlock:[PSPDFAnnotationGroupItem inkConfigurationBlock]]]],
///
/// [PSPDFAnnotationGroup groupWithItems:@[
/// [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringLine],
/// [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringPolyLine]]]
/// ]];
/// @endcode
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFAnnotationGroup : PSPDFModel

/// Creates a new annotation group with the provided items and designates the first item as the current choice.
/// @see groupWithItems:choice:
+ (instancetype)groupWithItems:(NSArray<__kindof PSPDFAnnotationGroupItem *> *)items;

/// Creates a new annotation group with the provided items and designates the item at index `choice` as the current selection.
/// @note Items will deep copied (don't rely on referential equality).
+ (instancetype)groupWithItems:(NSArray<__kindof PSPDFAnnotationGroupItem *> *)items choice:(NSUInteger)choice;

/// All set items. @see editableItems
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFAnnotationGroupItem *> *items;

/// The `items` filtered to only editable types.
/// The editable types are set by the hosting annotation toolbar.
@property (nonatomic, readonly) NSArray<__kindof PSPDFAnnotationGroupItem *> *editableItems;

/// The index of the currently selected item.
/// @note This corresponds to an index in `editableItems`.
/// Indexes outside of the `editableItems` range will be automatically adjusted.
@property (nonatomic) NSUInteger choice;

/// Updates the choice index to the first item with the selected type and variant.
/// Set variant to `nil`, if not relevant.
/// Returns `YES` is successful and `NO` if no items with the provided parameters were found.
- (BOOL)updateChoiceToItemWithType:(NSString *)type variant:(nullable NSString *)variant;

@end

NS_ASSUME_NONNULL_END
