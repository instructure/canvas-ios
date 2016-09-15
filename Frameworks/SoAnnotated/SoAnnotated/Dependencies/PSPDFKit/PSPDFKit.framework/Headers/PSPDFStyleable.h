//
//  PSPDFStyleable.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

/// Implement in your `UIViewController` subclass to be able to match the style of `PSPDFViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFStyleable <NSObject>

@optional

/// Proposed bar style.
@property (nonatomic) UIBarStyle barStyle;

/// Transparency flag.
@property (nonatomic) BOOL isBarTranslucent;

/// A Boolean value specifying whether the view controller always wants the status bar hidden.
/// If `YES`, then the view controller’s `prefersStatusBarHidden` should always return `YES`.
/// If `NO`, then the superclass’s implementation of `prefersStatusBarHidden` should be used,
/// which typically results in the status bar being hidden only in vertically compact environments.
@property (nonatomic) BOOL forcesStatusBarHidden;

@end
