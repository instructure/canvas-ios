//
//  PSPDFBrightnessManager.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Allows to manage device brightness.
 *  Includes additional software dimming to make the screen extra dark.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFBrightnessManager : NSObject

/// @section Configuration

/// Enables software dimming. Defaults to YES.
@property (nonatomic) BOOL wantsSoftwareDimming;

/// Enables additional software dimming to make the screen really dark. Defaults to YES.
@property (nonatomic) BOOL wantsAdditionalSoftwareDimming;

/// Defaults to 0.3. Only relevant if `wantsAdditionalSoftwareDimming` is YES.
/// Especially for special use cases like airplane software that requires additional dimming.
@property (nonatomic) CGFloat additionalBrightnessDimmingFactor;

/// Defaults to 0.6. If you set this to 1 the screen will be *completely* dark.
/// Only relevant if `wantsAdditionalSoftwareDimming` is YES.
@property (nonatomic) CGFloat maximumAdditionalBrightnessDimmingFactor;

/// @section Control

/// Brightness value 0..1.
/// Takes additional software dimming into account. Supports KVO.
@property (nonatomic) CGFloat brightness;

@end

NS_ASSUME_NONNULL_END
