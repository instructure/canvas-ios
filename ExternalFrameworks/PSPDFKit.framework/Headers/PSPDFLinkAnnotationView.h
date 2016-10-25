//
//  PSPDFLinkAnnotationView.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PSPDFAnnotationViewProtocol.h"
#import "PSPDFLinkAnnotationBaseView.h"

NS_ASSUME_NONNULL_BEGIN

/// Displays an annotation link.
PSPDF_CLASS_AVAILABLE @interface PSPDFLinkAnnotationView : PSPDFLinkAnnotationBaseView

/// Convenience setter for the borderColor. If you need more control use button.layer.*.
/// Defaults to `[UIColor colorWithRed:0.055f green:0.129f blue:0.800f alpha:0.1f]` (google-link-blue)
@property (nonatomic, nullable) UIColor *borderColor UI_APPEARANCE_SELECTOR;

/// Roundness of the border. Defaults to 4.
@property (nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/// Stroke width. Defaults to 1.
@property (nonatomic) CGFloat strokeWidth UI_APPEARANCE_SELECTOR;

/// Increases touch target by overspan pixel. Defaults to 15/15. Overspan is not visible.
@property (nonatomic) CGSize overspan UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
