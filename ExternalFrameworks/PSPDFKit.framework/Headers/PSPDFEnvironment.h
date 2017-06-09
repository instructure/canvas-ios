//
//  PSPDFEnvironment.h
//  PSPDFFoundation
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Availability.h>
#import <CoreGraphics/CoreGraphics.h>
#import <TargetConditionals.h>
// clang-format off
#if __has_include(<QuartzCore/QuartzCore.h>)
#import <QuartzCore/QuartzCore.h>
#endif
// clang-format on

#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

#import "PSPDFNamespace.h"
#import "PSPDFMacros.h"

#define PSPDF_STRINGIZE2(s) #s
#define PSPDF_STRINGIZE(s) PSPDF_STRINGIZE2(s)

#ifndef PSPDF_CUSTOM_PREFIX
#define PSPDF_STRING_PREFIX "PSPDF"
#else
#define PSPDF_STRING_PREFIX PSPDF_STRINGIZE(PSPDF_CUSTOM_PREFIX) "_PSPDF"
#endif

// clang-format off
#define PSPDF_HAS_JS_SUPPORT __has_include(<JavaScriptCore/JavaScriptCore.h>)
// clang-format on

#if TARGET_OS_OSX

#define UIColor NSColor
#define UIImage NSImage
#define UIFont NSFont
#define UIBezierPath NSBezierPath
#define UIFontDescriptor NSFontDescriptor

#define UIFontDescriptorTraitsAttribute NSFontTraitsAttribute
#define UIFontDescriptorSymbolicTraits NSFontSymbolicTraits
#define UIFontDescriptorTraitBold NSFontBoldTrait
#define UIFontDescriptorTraitItalic NSFontItalicTrait
#define UIFontDescriptorNameAttribute NSFontNameAttribute
#define UIFontDescriptorFamilyAttribute NSFontFamilyAttribute

#define NSUnderlineStyle NSInteger

#define NSTextAlignmentToCTTextAlignment PSPDFTextAlignmentToCTTextAlignment
PSPDF_EXPORT CTTextAlignment PSPDFTextAlignmentToCTTextAlignment(NSTextAlignment nsTextAlignment);

#define UIEdgeInsets NSEdgeInsets
#define UIEdgeInsetsZero NSEdgeInsetsZero
#define UIEdgeInsetsMake NSEdgeInsetsMake
#define UIEdgeInsetsEqualToEdgeInsets NSEdgeInsetsEqual

#define UIEdgeInsetsInsetRect PSPDFEdgeInsetInsetRect
#define UIEdgeInsetsFromString PSPDFEdgeInsetFromString
#define NSStringFromUIEdgeInsets NSStringFromPSPDFEdgeInset
PSPDF_EXPORT CGRect PSPDFEdgeInsetInsetRect(CGRect rect, UIEdgeInsets insets);
PSPDF_EXPORT NSString *NSStringFromPSPDFEdgeInset(UIEdgeInsets insets);
PSPDF_EXPORT UIEdgeInsets PSPDFEdgeInsetFromString(NSString *string);

#define NSStringFromCGPoint PSPDF_NSStringFromCGPoint
#define NSStringFromCGSize PSPDF_NSStringFromCGSize
#define NSStringFromCGRect PSPDF_NSStringFromCGRect
#define NSStringFromCGAffineTransform PSPDF_NSStringFromCGAffineTransform

PSPDF_EXPORT NSString *PSPDF_NSStringFromCGPoint(CGPoint point);
PSPDF_EXPORT NSString *PSPDF_NSStringFromCGSize(CGSize size);
PSPDF_EXPORT NSString *PSPDF_NSStringFromCGRect(CGRect rect);
PSPDF_EXPORT NSString *PSPDF_NSStringFromCGAffineTransform(CGAffineTransform transform);

#define CGPointFromString PSPDF_CGPointFromString
#define CGSizeFromString PSPDF_CGSizeFromString
#define CGRectFromString PSPDF_CGRectFromString
#define CGAffineTransformFromString PSPDF_CGAffineTransformFromString

PSPDF_EXPORT CGPoint PSPDF_CGPointFromString(NSString *string);
PSPDF_EXPORT CGSize PSPDF_CGSizeFromString(NSString *string);
PSPDF_EXPORT CGRect PSPDF_CGRectFromString(NSString *string);
PSPDF_EXPORT CGAffineTransform PSPDF_CGAffineTransformFromString(NSString *string);

#define UIApplicationDidReceiveMemoryWarningNotification PSPDFApplicationDidReceiveMemoryWarningNotification
#define UIApplicationWillEnterForegroundNotification NSApplicationWillBecomeActiveNotification
#define UIApplicationDidEnterBackgroundNotification NSApplicationDidHideNotification
#define UIApplicationWillTerminateNotification NSApplicationWillTerminateNotification
#define UIApplicationDidFinishLaunchingNotification NSApplicationDidFinishLaunchingNotification
PSPDF_EXPORT NSNotificationName const PSPDFApplicationDidReceiveMemoryWarningNotification;

// This is implemented on PSPDFDocument, but if we ifdef there, apppledoc has parsing issues.
PSPDF_AVAILABLE_DECL @protocol UIActivityItemSource
@end

#else

#define NSLineCapStyle CGLineCap
#define NSLineJoinStyle CGLineJoin

#if TARGET_OS_WATCH
#import "watchOS/PSPDFWatchOSSupport.h"
#endif

// Helper to get the shared application object, also for extensions.
PSPDF_EXPORT UIApplication *PSPDFSharedApplication(void);

#endif
