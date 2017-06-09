//
//  PSPDFPrintCoordinator.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocumentSharingCoordinator.h"
#import "PSPDFPrintConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// Coordinates the `PSPDFDocumentSharingViewController` and `UIPrintInteractionController`.
PSPDF_CLASS_AVAILABLE @interface PSPDFPrintCoordinator : PSPDFDocumentSharingCoordinator<UIPrintInteractionControllerDelegate, UIPrinterPickerControllerDelegate>

/**
 Common settings that define how printing should be handled
 @see PSPDFConfiguration (where this is set)
 */
@property (nonatomic) PSPDFPrintConfiguration *printConfiguration;

@end

@interface PSPDFPrintCoordinator (SubclassingHooks)

/**
 Subclass to allow setting default printer info or changing the printer job name.
 (see `printerID`, https://stackoverflow.com/questions/12898476/airprint-set-default-printer-in-uiprintinteractioncontroller)
 */
@property (nonatomic, readonly) UIPrintInfo *printInfo;

/// The print interaction controller, while visible.
@property (nonatomic, weak, readonly) UIPrintInteractionController *printInteractionController;

@end

NS_ASSUME_NONNULL_END
