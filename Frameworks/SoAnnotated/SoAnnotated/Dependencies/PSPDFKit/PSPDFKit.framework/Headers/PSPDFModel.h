//
//  PSPDFModel.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
//  Based on GitHub's Mantle project, MIT licensed. See ACKNOWLEDGEMENTS for details.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// An abstract base class for model objects, using reflection to provide
/// sensible default behaviors.
///
/// The default implementations of <NSCopying>, -hash, and -isEqual: make use of
/// the +propertyKeys method.
PSPDF_CLASS_AVAILABLE @interface PSPDFModel : NSObject <NSCopying>

/// Returns a new instance of the receiver initialized using
/// -initWithDictionary:error:.
+ (instancetype)modelWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionaryValue error:(NSError **)error;

/// Initializes the receiver using key-value coding, setting the keys and values
/// in the given dictionary.
///
/// dictionaryValue - Property keys and values to set on the receiver. Any NSNull
///                   values will be converted to nil before being used. KVC
///                   validation methods will automatically be invoked for all of
///                   the properties given. If nil, this method is equivalent to
///                   -init.
/// error           - If not NULL, this may be set to any error that occurs
///                   (like a KVC validation error).
///
/// Returns an initialized model object, or nil if validation failed.
- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionaryValue error:(NSError **)error;

/// Returns the keys for all @property declarations, except for `readonly`
/// properties without ivars, or properties on PSPDFModel itself.
+ (NSOrderedSet<NSString *> *)propertyKeys;
/// Cached variant. Do not subclass.
+ (NSArray<NSString *> *)cachedPropertyKeys;
/// Returns an opaque object for `dictionaryWithSharedKeySet:`.
+ (id)cachedPropertyKeySet;

/// Returns the property keys that should be compared using pointers rather than
/// structurally. This is designed to be overwritten in subclasses, the default
/// implementation here returns an empty set.
+ (NSOrderedSet<NSString *> *)propertyKeysWithReferentialEquality;

/// A dictionary representing the properties of the receiver.
///
/// The default implementation combines the values corresponding to all
/// +propertyKeys into a dictionary, with any nil values represented by NSNull.
///
/// This property must never be nil.
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *dictionaryValue;

/// Merges the value of the given key on the receiver with the value of the same
/// key from the given model object, giving precedence to the other model object.
///
/// By default, this method looks for a `-merge<Key>FromModel:` method on the
/// receiver, and invokes it if found. If not found, and `model` is not nil, the
/// value for the given key is taken from `model`.
- (void)mergeValueForKey:(NSString *)key fromModel:(PSPDFModel *)model;

/// Merges the values of the given model object into the receiver, using
/// -mergeValueForKey:fromModel: for each key in +propertyKeys.
///
/// `model` must be an instance of the receiver's class or a subclass thereof.
- (void)mergeValuesForKeysFromModel:(PSPDFModel *)model;

@end

@interface PSPDFModel (NSCoding) <NSCoding> @end

NS_ASSUME_NONNULL_END
