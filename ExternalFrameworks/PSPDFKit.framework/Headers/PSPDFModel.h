//
//  PSPDFModel.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
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

/**
 An abstract base class for model objects, using reflection to provide
 sensible default behaviors.

 The default implementations of <NSCopying>, -hash, and -isEqual: make use of
 the +propertyKeys method.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFModel : NSObject<NSCopying>

/**
 Returns a new instance of the receiver initialized using
 -initWithDictionary:error:.
 */
+ (instancetype)modelWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionaryValue error:(NSError **)error;

/**
 Initializes the receiver using key-value coding, setting the keys and values
 in the given dictionary.

 dictionaryValue - Property keys and values to set on the receiver. Any NSNull
 values will be converted to nil before being used. KVC
 validation methods will automatically be invoked for all of
 the properties given. If nil, this method is equivalent to
 -init.
 error           - If not NULL, this may be set to any error that occurs
 (like a KVC validation error).

 Returns an initialized model object, or nil if validation failed.
 */
- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionaryValue error:(NSError **)error;

/**
 Returns the keys for all @property declarations, except for `readonly`
 properties without ivars, or properties on PSPDFModel itself.
 */
@property (nonatomic, class, readonly) NSOrderedSet<NSString *> *propertyKeys;

/**
 A dictionary representing the properties of the receiver.

 The default implementation combines the values corresponding to all
 +propertyKeys into a dictionary, with any nil values represented by NSNull.

 This property must never be nil.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *dictionaryValue;

@end

@interface PSPDFModel (NSCoding) <NSCoding>
@end

NS_ASSUME_NONNULL_END
