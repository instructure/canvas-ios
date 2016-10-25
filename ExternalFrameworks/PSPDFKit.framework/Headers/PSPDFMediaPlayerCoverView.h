//
//  PSPDFMediaPlayerCoverView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// If the cover option is set, this is showed until the play button is pressed.
PSPDF_CLASS_AVAILABLE @interface PSPDFMediaPlayerCoverView : UIView

/// The color of the play button.
@property (nonatomic, nullable) UIColor *playButtonColor UI_APPEARANCE_SELECTOR;

/// The image of the play button. If set to `nil` the default play button appearance will be used.
@property (nonatomic, nullable) UIImage *playButtonImage UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
