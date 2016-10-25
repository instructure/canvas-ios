//
//  PSPDFRenditionAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFScreenAnnotation;

typedef NS_ENUM(NSInteger, PSPDFRenditionActionType) {
    PSPDFRenditionActionTypeUnknown = -1,
    PSPDFRenditionActionTypePlayStop,
    PSPDFRenditionActionTypeStop,
    PSPDFRenditionActionTypePause,
    PSPDFRenditionActionTypeResume,
    PSPDFRenditionActionTypePlay
} PSPDF_ENUM_AVAILABLE;

PSPDF_EXPORT NSString *const PSPDFRenditionActionTypeTransformerName;

/// A rendition action (PDF 1.5) controls the playing of multimedia content (see PDF Reference 1.7, 13.2, “Multimedia”).
/// @note JavaScript actions are not supported.
PSPDF_CLASS_AVAILABLE @interface PSPDFRenditionAction : PSPDFAction

/// Designated initializer.
- (instancetype)initWithActionType:(PSPDFRenditionActionType)actionType javaScript:(nullable NSString *)javaScript annotation:(nullable PSPDFScreenAnnotation *)annotation;

/// The rendition action type.
@property (nonatomic, readonly) PSPDFRenditionActionType actionType;

/// The associated screen annotation. Optional. Will link to an already existing annotation.
@property (nonatomic, weak, readonly) PSPDFScreenAnnotation *annotation;

/// Optional. A JavaScript script that shall be executed when the action is triggered.
@property (nonatomic, readonly, nullable) NSString *javaScript;

@end

NS_ASSUME_NONNULL_END
