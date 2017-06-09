//
//  PSPDFChoiceFormField.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFormField.h"
#import "PSPDFFormOption.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a choice form field in a PDF form. This allows the user to select one of the given options or, if `isEdit`
 is `YES`, enter their own option value.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFChoiceFormField : PSPDFFormField

PSPDF_EMPTY_INIT_UNAVAILABLE

/// If set, the field is a combo box; if clear, the field is a list box.
@property (nonatomic, readonly) BOOL isCombo;

/// If set, the combo box shall include an editable text box as well as a drop-down list; if clear, it shall include only a drop-down list. This flag shall be used only if the Combo flag is set.
@property (nonatomic, readonly) BOOL isEdit;

/// (PDF 1.4) If set, more than one of the field’s option items may be selected simultaneously; if clear, at most one item shall be selected.
@property (nonatomic, readonly) BOOL isMultiSelect;

/// (PDF 1.5) If set, the new value shall be committed as soon as a selection is made (commonly with the pointing device). In this case, supplying a value for a field involves three actions: selecting the field for fill-in, selecting a choice for the fill-in value, and leaving that field, which finalizes or “commits” the data choice and triggers any actions associated with the entry or changing of this data. If this flag is on, then processing does not wait for leaving the field action to occur,
/// but immediately proceeds to the third step. This option enables applications to perform an action once a selection is made, without requiring the user to exit the field. If clear, the new value is not committed until the user exits the field.
@property (nonatomic, readonly) BOOL commitOnSelChange;

/// (PDF 1.4) If set, text entered in the field shall not be spellchecked. This flag shall not be used unless the Combo and Edit flags are both set.
@property (nonatomic, readonly) BOOL doNotSpellCheck;

/**
 An array of options that will be presented to the user.
 This can also be used to modify the options presented to the user.
 @note If you save the document after modifying options, the new options will be preserved in the PDF file.
 */
@property (nonatomic, copy) NSArray<PSPDFFormOption *> *options;

/// (Sometimes required, otherwise optional; PDF 1.4) For choice fields that allow multiple selection (MultiSelect flag set), an array of integers, sorted in ascending order, representing the zero-based indices in the Opt array of the currently selected option items. This entry shall be used when two or more elements in the Opt array have different names but the same export value or when the value of the choice field is an array. This entry should not be used for choice fields that do not allow
/// multiple selection. If the items identified by this entry differ from those in the V entry of the field dictionary (see discussion following this Table), the V entry shall be used.
@property (nonatomic, copy, nullable) NSIndexSet *selectedIndices;

/// For combo boxes only, is the selection a default or custom value
@property (nonatomic, readonly) BOOL customSelection;

/// Custom text.
@property (nonatomic, copy, nullable) NSString *customText;

@end

NS_ASSUME_NONNULL_END
