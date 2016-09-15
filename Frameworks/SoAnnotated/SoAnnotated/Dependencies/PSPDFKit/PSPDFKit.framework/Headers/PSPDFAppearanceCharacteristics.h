//
//  PSPDFAppearanceCharacteristics.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"
#import "PSPDFJSONAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFStream, PSPDFIconFit;

typedef NS_ENUM(NSUInteger, PSPDFAppearanceCharacteristicsTextPosition) {
    /// 0 No icon; caption only
    PSPDFAppearanceCharacteristicsTextPositionNoIcon,
    /// 1 No caption; icon only
    PSPDFAppearanceCharacteristicsTextPositionNoCaption,
    /// 2 Caption below the icon
    PSPDFAppearanceCharacteristicsTextPositionCaptionBelowIcon,
    /// 3 Caption above the icon
    PSPDFAppearanceCharacteristicsTextPositionCaptionAboveIcon,
    /// 4 Caption to the right of the icon
    PSPDFAppearanceCharacteristicsTextPositionCaptionLeftFromIcon,
    /// 5 Caption to the left of the icon
    PSPDFAppearanceCharacteristicsTextPositionCaptionRightFromIcon,
    /// 6 Caption overlaid directly on the icon
    PSPDFAppearanceCharacteristicsTextPositionCaptionOverlaid
} PSPDF_ENUM_AVAILABLE;

/// Saves all elements of the appearance characteristics dictionary. Not all options are supported yet.
//// Rotation, border and fill color are defined in the widget annotation directly.
PSPDF_CLASS_AVAILABLE @interface PSPDFAppearanceCharacteristics : PSPDFModel <PSPDFJSONSerializing>

/// (Optional; button fields only) The widget annotation’s normal caption, which shall be displayed when it is not interacting with the user.
/// Unlike the remaining entries listed in this Table, which apply only to widget annotations associated with pushbutton fields (see Pushbuttons in 12.7.4.2, “Button Fields”), the CA entry may be used with any type of button field, including check boxes (see Check Boxes in 12.7.4.2, “Button Fields”) and radio buttons (Radio Buttons in 12.7.4.2, “Button Fields”).
@property (nonatomic, copy, nullable) NSString *normalCaption;

/// (Optional; pushbutton fields only) The widget annotation’s rollover caption, which shall be displayed when the user rolls the cursor into its active area without pressing the mouse button.
@property (nonatomic, copy, nullable) NSString *rolloverCaption;

/// (Optional; pushbutton fields only) The widget annotation’s alternate (down) caption, which shall be displayed when the mouse button is pressed within its active area.
@property (nonatomic, copy, nullable) NSString *alternateCaption;

/// (Optional; pushbutton fields only) A code indicating where to position the text of the widget annotation’s caption relative to its icon. Default value: 0.
@property (nonatomic) PSPDFAppearanceCharacteristicsTextPosition textPosition;

/// (Optional; pushbutton fields only; shall be an indirect reference) A form XObject defining the widget annotation’s normal icon, which shall be displayed when it is not interacting with the user.
@property (nonatomic, nullable) PSPDFStream *normalIcon;

/// Optional; pushbutton fields only; shall be an indirect reference) A form XObject defining the widget annotation’s rollover icon, which shall be displayed when the user rolls the cursor into its active area without pressing the mouse button.
@property (nonatomic, nullable) PSPDFStream *rolloverIcon;

/// (Optional; pushbutton fields only; shall be an indirect reference) A form XObject defining the widget annotation’s alternate (down) icon, which shall be displayed when the mouse button is pressed within its active area.
@property (nonatomic, nullable) PSPDFStream *alternateIcon;

/// (Optional; pushbutton fields only) An icon fit dictionary (see Table 247) specifying how the widget annotation’s icon shall be displayed within its annotation rectangle. If present, the icon fit dictionary shall apply to all of the annotation’s icons (normal, rollover, and alternate).
@property (nonatomic, nullable) PSPDFIconFit *iconFit;

@end

@interface PSPDFAppearanceCharacteristics (PDFRepresentation)

/// Not a complete /MK dictionary (some data is in the widget annotation as well)
@property (nonatomic, readonly, copy) NSString *partialPDFString;

@end

NS_ASSUME_NONNULL_END
