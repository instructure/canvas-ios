//
//  PSPDFChoiceFormElement.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFormElement.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFChoiceFormField, PSPDFFormOption;

/// Choice Form Element Flags.
typedef NS_OPTIONS(NSUInteger, PSPDFChoiceFlag) {
    PSPDFChoiceFlagCombo = 1 << (18 - 1),
    PSPDFChoiceFlagEdit = 1 << (19 - 1),
    PSPDFChoiceFlagSort = 1 << (20 - 1),
    PSPDFChoiceFlagMultiSelect = 1 << (22 - 1),
    PSPDFChoiceFlagDoNotSpellCheck = 1 << (23 - 1),
    PSPDFChoiceFlagCommitOnSelChange = 1 << (27 - 1),
} PSPDF_ENUM_AVAILABLE;

@class PSPDFViewController;

/// Choice Form Element.
PSPDF_CLASS_AVAILABLE @interface PSPDFChoiceFormElement : PSPDFFormElement

/// (Optional) An array of options that shall be presented to the user.
@property (nonatomic, copy, readonly, nullable) NSArray<PSPDFFormOption *> *options;

/// (Sometimes required, otherwise optional; PDF 1.4) For choice fields that allow multiple selection (MultiSelect flag set), an array of integers, sorted in ascending order, representing the zero-based indices in the Opt array of the currently selected option items. This entry shall be used when two or more elements in the Opt array have different names but the same export value or when the value of the choice field is an array. This entry should not be used for choice fields that do not allow
/// multiple selection. If the items identified by this entry differ from those in the V entry of the field dictionary (see discussion following this Table), the V entry shall be used.
@property (nonatomic, copy, nullable) NSIndexSet *selectedIndices;

/// If any indices are selected, returns the corresponding selected `PSPDFFormOption`.
@property (nonatomic, copy, readonly, nullable) NSArray<PSPDFFormOption *> *selectedOptions;

/// For combo boxes only, is the selection a default or custom value
@property (nonatomic, readonly) BOOL customSelection;

/// Optional. For scrollable list boxes, the top index (the index in the Opt array of the first option visible in the list). Default value: 0.
@property (nonatomic, readonly) NSUInteger topIndex;

/// Custom text.
@property (nonatomic, copy, nullable) NSString *customText;

/// Returns the parent property `formField` cast to the appropriate `PSPDFChoiceFormField` type.
@property (nonatomic, readonly, nullable) PSPDFChoiceFormField *choiceFormField;

@end

NS_ASSUME_NONNULL_END
