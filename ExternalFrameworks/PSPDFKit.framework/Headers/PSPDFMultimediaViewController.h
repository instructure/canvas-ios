//
//  PSPDFMultimediaViewController.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAction, PSPDFConfiguration;
@protocol PSPDFOverridable;

/// A key in the `options` dictionary when initializing a multimedia plugin. Maps to the `PSPDFLinkAnnotation`
/// that should be used for the multimedia content.
PSPDF_EXPORT NSString *const PSPDFMultimediaLinkAnnotationKey;

/// A protocol that defines the interface that multimedia view controller plugins must conform to.
/// @warning The class that implements this protocol must be a `UIViewController` subclass!
PSPDF_AVAILABLE_DECL @protocol PSPDFMultimediaViewController <NSObject>

/// Indicates if the controller is currently in fullscreen mode or changes the state.
@property (nonatomic, getter=isFullscreen) BOOL fullscreen;
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

/// Indicates if the controller is transitioning between fullscreen and embedded mode.
@property (nonatomic, getter=isTransitioning) BOOL transitioning;

/// The zoom scale at which the controller is presented.
@property (nonatomic) CGFloat zoomScale;

/// The delegate that can be used to override classes.
@property (nonatomic, weak) id<PSPDFOverridable> overrideDelegate;

/// Called when a multimedia action (either `PSPDFRenditionAction` or `PSPDFRichMediaExecuteAction`)
/// should be performed.
- (void)performAction:(PSPDFAction *)action;

@optional

/// Configures the controller with the given `PSPDFConfiguration`.
- (void)configure:(PSPDFConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
