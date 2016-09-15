//
//  PSPDFHideAction.h
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
#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// A hide action (PDF 1.2) hides or shows one or more annotations on the screen by setting
/// or clearing their Hidden flags (see 12.5.3, “Annotation Flags”).
/// This type of action can be used in combination with appearance streams and trigger events
/// (Sections 12.5.5, “Appearance Streams,” and 12.6.3, “Trigger Events”) to display pop-up help information on the screen.
PSPDF_CLASS_AVAILABLE @interface PSPDFHideAction : PSPDFAction

/// Designated initializers.
- (instancetype)initWithAssociatedAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations shouldHide:(BOOL)shouldHide;

/// Either hide (YES) or show (NO) the referenced annotation/form object.
/// This is achieved by removing both `PSPDFAnnotationFlagInvisible` and `PSPDFAnnotationFlagNoView` and toggling `PSPDFAnnotationFlagHidden`.
@property (nonatomic, readonly) BOOL shouldHide;

/// The associated annotations. (weakly referenced)
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFAnnotation *> *annotations;

@end

NS_ASSUME_NONNULL_END
