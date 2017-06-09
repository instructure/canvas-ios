//
//  PSPDFStylusTouch.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// Defines classifications for a stylus touch and how a touch should be handled.
typedef NS_ENUM(NSInteger, PSPDFStylusTouchClassification) {
    /// An unknown touch while the stylus is disconnected.
    PSPDFStylusTouchClassificationUnknownDisconnected,
    /// An unkown touch.
    PSPDFStylusTouchClassificationUnknown,
    /// A touch done with the finger.
    PSPDFStylusTouchClassificationFinger,
    /// A touch done with the palm of the hand.
    PSPDFStylusTouchClassificationPalm,
    /// A touch done with the stylus classified as a pen.
    PSPDFStylusTouchClassificationPen,
    /// A touch done with the stylus classified as eraser.
    PSPDFStylusTouchClassificationEraser,
} PSPDF_ENUM_AVAILABLE;

/// Protocol for stylus touches.
PSPDF_AVAILABLE_DECL @protocol PSPDFStylusTouch<NSObject>

@optional

/**
 Returns the point computed as the location in a given view of the gesture represented by the receiver.
 @param view A UIView object on which the gesture took place.
 @return A point in the local coordinate system of view that identifies the location of the gesture.
 */
- (CGPoint)locationInView:(UIView *)view;

/// The classification of the touch. Defines how the touch will be handled.
@property (nonatomic, readonly) PSPDFStylusTouchClassification classification;

/**
 The pressure value of the touch on the screen.
 Can be between 0 and 1.
 */
@property (nonatomic, readonly) CGFloat pressure;

@end

/// The default class for any stylus touch.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultStylusTouch : NSObject<PSPDFStylusTouch>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Create a new instance with a touch classification and a pressure value.
- (instancetype)initWithClassification:(PSPDFStylusTouchClassification)classification pressure:(CGFloat)pressure NS_DESIGNATED_INITIALIZER;

/// The classification of the touch. Defines how the touch will be handled.
@property (nonatomic, readonly) PSPDFStylusTouchClassification classification;

/**
 The pressure value of the touch on the screen.
 Can be between 0 and 1.
 */
@property (nonatomic, readonly) CGFloat pressure;

@end

/// Info of a stylus touch when it will change the classification.
PSPDF_CLASS_AVAILABLE @interface PSPDFStylusTouchClassificationInfo : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Create a new stylus touch classification info instance.

 @param touch The `UITouch` object.
 @param touchID The ID of the touch. Specify `NSNotFound` if there is none.
 @param oldValue The old stylus touch classification before the change.
 @param newValue The new stylus touch classification after the change.
 */
- (instancetype)initWithTouch:(nullable UITouch *)touch touchID:(NSInteger)touchID oldValue:(PSPDFStylusTouchClassification)oldValue newValue:(PSPDFStylusTouchClassification)newValue NS_DESIGNATED_INITIALIZER;

/**
 `touch` is a weak property, because - quoting Apple's `UITouch` documentation: "Never retain a touch object when handling an event.
 If you need to keep information about a touch from one touch phase to another, copy that information from the touch."
 @see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITouch_Class/
 */
@property (nonatomic, weak, readonly) UITouch *touch;

/// The ID of the touch. Can be `NSNotFound` if there is no ID.
@property (nonatomic, readonly) NSInteger touchID;

/// The old stylus touch classification before the change.
@property (nonatomic, readonly) PSPDFStylusTouchClassification oldValue;

/// The new stylus touch classification after the change.
@property (nonatomic, readonly) PSPDFStylusTouchClassification newValue;

@end

NS_ASSUME_NONNULL_END
