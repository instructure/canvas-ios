//
//  PSPDFFontPickerViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFFontPickerViewController;

/// Delegate for `PSPDFFontPickerViewController`, calls back when a font is selected.
PSPDF_AVAILABLE_DECL @protocol PSPDFFontPickerViewControllerDelegate <PSPDFOverridable>

/// A font has been selected.
- (void)fontPickerViewController:(PSPDFFontPickerViewController *)fontPickerViewController didSelectFont:(nullable UIFont *)selectedFont;

@end

/// Font picker that allows to select a font and customize the style.
PSPDF_CLASS_AVAILABLE @interface PSPDFFontPickerViewController : PSPDFStaticTableViewController

/// Initialize with a list of displayed `UIFontDescriptors`.
/// If `fontFamilyDescriptors` is nil, a default list of all commonly used font families is used.
- (instancetype)initWithFontFamilyDescriptors:(nullable NSArray<UIFontDescriptor*> *)fontFamilyDescriptors NS_DESIGNATED_INITIALIZER;

/// All available font family names as `UIFontDescriptors`.
@property (nonatomic, copy, readonly) NSArray<UIFontDescriptor*> *fontFamilyDescriptors;

/// The currently selected font.
@property (nonatomic, nullable) UIFont *selectedFont;

/// We highlight common fonts on top to make selection easier. This must be a subset of `fontFamilyDescriptors`.
/// Set this to nil to have no highlight set.
@property (nonatomic, nullable)  NSArray<UIFontDescriptor*> *highlightedFontFamilyDescriptors;

/// Whether to allow search. Must be set before the view is loaded. Defaults to YES.
@property (nonatomic) BOOL searchEnabled;

/// Enable font downloading from Apple's servers. Defaults to YES.
/// @note See http://support.apple.com/kb/HT5484 for the full list.
@property (nonatomic) BOOL showDownloadableFonts;

/// The font picker delegate - notifies when a font is selected.
@property (nonatomic, weak) IBOutlet id<PSPDFFontPickerViewControllerDelegate> delegate;

@end

@interface UIFontDescriptor (Blacklisting)

/// By default certain less commonly used fonts are blocked automatically.
/// Array expects a list of regular expression strings.
/// @note Needs to be set before the font picker is displayed.
+ (void)setPSPDFDefaultBlacklist:(NSArray<NSString *> *)defaultBlacklist;
+ (NSArray<NSString *> *)pspdf_defaultBlacklist;

@end

NS_ASSUME_NONNULL_END
