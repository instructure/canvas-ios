//
//  PSPDFApplePencilDriver.h
//  PSPDFKit
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFStylusDriver.h"

NS_ASSUME_NONNULL_BEGIN

/// Notification posted on the main thread whenever `detected` is set to `YES` even if it was `YES` before.
PSPDF_EXPORT NSNotificationName const PSPDFApplePencilDetectedNotification;

/// Notification posted on the main thread whenever `detected` changes value.
PSPDF_EXPORT NSNotificationName const PSPDFApplePencilDetectedChangedNotification;

/**
 When this class is enabled on `PSPDFStylusManager` compatible annotations types may be created only with
 touches of type `UITouchTypeStylus`. If enabled and a compatible annotation tool is selected, users can
 annotate with Apple Pencil while taping and scrolling as normal with finger touches. Compatible annotations
 types are ink, lines, polylines, polygons, and markup types like highlight.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFApplePencilDriver : NSObject<PSPDFStylusDriver>

/**
 Whether an Apple Pencil has been detected in the lifetime of the process.
 This should be accessed only on the main thread.
 PSPDFKit sets this to `YES` whenever a touch of type `UITouchTypeStylus` begins on a page view.
 This may be set earlier to show Apple Pencil availability in the UI sooner.
 */
@property (nonatomic, class, getter=wasDetected) BOOL detected;

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Creates a new instance of the driver and sets `delegate`.
- (instancetype)initWithDelegate:(id<PSPDFStylusDriverDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// Delegate to be notified when Apple Pencil connection status changes (when a touch from one is detected).
/// Other methods in `PSPDFStylusDriverDelegate` are not applicable and will not be called.
@property (nonatomic, weak) id<PSPDFStylusDriverDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
