//
//  PSPDFOutlineElement.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBookmark.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents a single outline/table of contents element.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineElement : PSPDFBookmark

/// Init with title, page, child elements and indentation level.
- (instancetype)initWithTitle:(nullable NSString *)title color:(nullable UIColor *)color fontTraits:(UIFontDescriptorSymbolicTraits)fontTraits action:(nullable PSPDFAction *)action children:(nullable NSArray<PSPDFOutlineElement*> *)children level:(NSUInteger)level NS_DESIGNATED_INITIALIZER;

/// Returns all elements + flattened subelements if they are expanded
@property (nonatomic, readonly) NSArray<PSPDFOutlineElement *> *flattenedChildren;

/// All elements, ignores expanded state.
@property (nonatomic, readonly) NSArray<PSPDFOutlineElement *> *allFlattenedChildren;

/// Outline title.
@property (nonatomic, copy, readonly, nullable) NSString *title;

/// Bookmark can have a color. (Optional; PDF 1.4)
/// PSDPFKit defaults to system text color when presenting if nil.
@property (nonatomic, readonly, nullable) UIColor *color;

/// A bookmark can be optionally bold or italic. (Optional; PDF 1.4)
@property (nonatomic, readonly) UIFontDescriptorSymbolicTraits fontTraits;

/// Child elements.
@property (nonatomic, copy, readonly, nullable) NSArray<PSPDFOutlineElement *> *children;

/// Current outline level.
@property (nonatomic, readonly) NSUInteger level;

/// Expansion state of current outline element (will not be persisted)
@property (atomic, getter=isExpanded) BOOL expanded;

@end

NS_ASSUME_NONNULL_END
