//
//  PSPDFKit+PSPDFUI.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFKit.h"
#import "PSPDFApplication.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSpeechController, PSPDFStylusManager;

@interface PSPDFKit (Services)

/// Exposes application services.
@property (nonatomic) id <PSPDFApplication> application;

/// The global speech controller object.
@property (nonatomic, readonly) PSPDFSpeechController *speechController;

/// The stylus manager. Lazily loaded.
@property (nonatomic, readonly, nullable) PSPDFStylusManager *stylusManager;

@end

NS_ASSUME_NONNULL_END
