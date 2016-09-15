//
//  PSPDFAnnotationStyleManager.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFAnnotationStyle.h"
#import "PSPDFPlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// This key will return the last used style.
PSPDF_EXPORT NSString *const PSPDFStyleManagerLastUsedStylesKey;

/// This key will mark styles as generic, thus they'll be returned
/// with all other style types except the last used trait.
PSPDF_EXPORT NSString *const PSPDFStyleManagerGenericStylesKey;

/// Color preset type
PSPDF_EXPORT NSString *const PSPDFStyleManagerColorPresetKey;

/// The style manager will save UI-specific properties for annotations and apply them after creation.
/// It also offers a selection of user-defined styles.
/// There are three categories: Last used, key-specific and generic styles.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationStyleManager <PSPDFPlugin>

/// Keeps a list of style keys we want to listen to (like `color` or `lineWidth`).
/// @note If you want to disable automatic style saving, set this to nil.
@property (atomic, copy, nullable) NSSet *styleKeys;

/// When annotations are changed and this is enabled, the defaults are updated accordingly.
/// This defaults to YES.
@property (nonatomic) BOOL shouldUpdateDefaultsForAnnotationChanges;

/// Set default annotation styles.
/// This is the perfect place to set your own default annotation styles.
- (void)setupDefaultStylesIfNeeded;

/// Returns the 'last used' annotation style, a special variant that is kept per annotation string type.
/// Might return nil if there isn't anything saved yet.
- (nullable NSArray<PSPDFAnnotationStyle *> *)stylesForKey:(NSString *)key;

/// Adds a style on the key store.
- (void)addStyle:(PSPDFAnnotationStyle *)style forKey:(NSString *)key;

/// Removes a style from the key store.
- (void)removeStyle:(PSPDFAnnotationStyle *)style forKey:(NSString *)key;

/// @name Convenience Helpers

/// Get the last used style for `key`.
- (nullable PSPDFAnnotationStyle *)lastUsedStyleForKey:(NSString *)key;

/// Convenience method. Will fetch the last used style for `key` and fetches the styleProperty for it. Might return nil.
- (nullable id)lastUsedProperty:(NSString *)styleProperty forKey:(NSString *)key;

/// Convenience method. Will set the last used style for `key` and `styleProperty`.
/// `value` might be a boxed CGFloat, color or whatever matches the property.
/// `styleProperty` is the NSString-name for the property (e.g. `NSStringFromSelector(@ selector(fontSize))`
/// `key` is the annotation key, e.g. PSPDFAnnotationStringFreeText.
- (void)setLastUsedValue:(nullable id)value forProperty:(NSString *)styleProperty forKey:(NSString *)key;

/// @name Presets

/// Returns default presets for a given `key` and `type`. Override to customize.
/// @see presetsForKey:type:
/// @note The implementation should be thread safe.
- (nullable NSArray<__kindof PSPDFModel *> *)defaultPresetsForKey:(NSString *)key type:(NSString *)type;

/// Get the color presets for a specified key and preset type.
/// Returns an array of objects corresponding to the preset type (e.g, `PSPDFColorPreset`).
/// @property key The annotation key, e.g. PSPDFAnnotationStringFreeText.
/// @property type The preset type, e.g. PSPDFStyleManagerColorPresetKey (see PSPDFAnnotationStyleManager.h).
- (nullable NSArray<__kindof PSPDFModel *> *)presetsForKey:(NSString *)key type:(NSString *)type;

/// Updates the presets for the specified key and preset type.
/// @property presets An array of presets to save. They object must conform to `NSCoding`. Setting nil removes the presets from storage and reverts to the default presets (if set). 
/// @property key The annotation key, e.g. PSPDFAnnotationStringFreeText.
/// @property type The preset type, e.g. PSPDFStyleManagerColorPresetKey (see PSPDFAnnotationStyleManager.h).
- (void)setPresets:(nullable NSArray<__kindof PSPDFModel *> *)presets forKey:(NSString *)key type:(NSString *)type;

/// Checks if the preset at the given index differs from its default value. 
/// @property presets Index of preset in the preset array.
/// @property key The annotation key, e.g. PSPDFAnnotationStringFreeText.
/// @property type The preset type, e.g. PSPDFStyleManagerColorPresetKey (see PSPDFAnnotationStyleManager.h).
- (BOOL)isPresetModifiedAtIndex:(NSUInteger)index forKey:(NSString *)key type:(NSString *)type;

/// Resets the preset at the given index to its default value.
/// @property presets Index of preset in the preset array.
/// @property key The annotation key, e.g. PSPDFAnnotationStringFreeText.
/// @property type The preset type, e.g. PSPDFStyleManagerColorPresetKey (see PSPDFAnnotationStyleManager.h).
- (BOOL)resetPresetAtIndex:(NSUInteger)idx forKey:(NSString *)key type:(NSString *)type;

@end

/// The default implementation for the style manager.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultAnnotationStyleManager : NSObject <PSPDFAnnotationStyleManager> @end

NS_ASSUME_NONNULL_END
