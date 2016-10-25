//
//  PSPDFStylusTouch.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSPDFStylusTouchClassification) {
    PSPDFStylusTouchClassificationUnknownDisconnected,
    PSPDFStylusTouchClassificationUnknown,
    PSPDFStylusTouchClassificationFinger,
    PSPDFStylusTouchClassificationPalm,
    PSPDFStylusTouchClassificationPen,
    PSPDFStylusTouchClassificationEraser,
} PSPDF_ENUM_AVAILABLE;

PSPDF_AVAILABLE_DECL @protocol PSPDFStylusTouch <NSObject>

@optional

- (CGPoint)locationInView:(UIView *)view;
@property (nonatomic, readonly) PSPDFStylusTouchClassification classification;
@property (nonatomic, readonly) CGFloat pressure;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultStylusTouch : NSObject <PSPDFStylusTouch>

PSPDF_EMPTY_INIT_UNAVAILABLE

- (instancetype)initWithClassification:(PSPDFStylusTouchClassification)classification pressure:(CGFloat)pressure NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) PSPDFStylusTouchClassification classification;

@property (nonatomic, readonly) CGFloat pressure; // can be 0..1;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFStylusTouchClassificationInfo : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

- (instancetype)initWithTouch:(nullable UITouch *)touch touchID:(NSInteger)touchID oldValue:(PSPDFStylusTouchClassification)oldValue newValue:(PSPDFStylusTouchClassification)newValue NS_DESIGNATED_INITIALIZER;

// `touch` is a weak property, because - quoting Apple's `UITouch` documentation: "Never retain a touch object when handling an event.
// If you need to keep information about a touch from one touch phase to another, copy that information from the touch."
// See https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITouch_Class/
@property (nonatomic, weak, readonly) UITouch *touch;
@property (nonatomic, readonly) NSInteger touchID;
@property (nonatomic, readonly) PSPDFStylusTouchClassification oldValue;
@property (nonatomic, readonly) PSPDFStylusTouchClassification newValue;

@end

NS_ASSUME_NONNULL_END
