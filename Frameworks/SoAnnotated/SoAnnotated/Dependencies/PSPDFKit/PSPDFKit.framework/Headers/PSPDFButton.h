//
//  PSPDFButton.h
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

@class PSPDFButton;

typedef void (^PSPDFButtonActionBlock)(PSPDFButton *button);

/// A collection of useful extensions to `UIButton`.
PSPDF_CLASS_AVAILABLE @interface PSPDFButton : UIButton

/// You can use this property to increase or decrease the hit area of a button. Use negative
/// values to increase and positive values to decrease the touch area. Defaults to
/// `UIEdgeInsetsZero`.
@property (nonatomic) UIEdgeInsets touchAreaInsets;

/// Switch the default button image position.
/// Defaults to NO (image on left). 
@property (nonatomic) BOOL positionImageOnRight;

/// A block that is called when a button action is performed.
/// Setting this property uses UIControlEventTouchUpInside by default.
@property (nonatomic, copy) PSPDFButtonActionBlock actionBlock;

/// Sets the `actionBlock` property to the provided block, registering for events specified by `controlEvents`.
- (void)setActionBlock:(nullable PSPDFButtonActionBlock)actionBlock forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
