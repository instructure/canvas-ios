//
//  PSPDFEnvironment.h
//  PSPDFFoundation
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PSPDFMacros.h"

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))

#define PSPDF_TARGET_MAC 1
#define PSPDF_TARGET_TV  0
#define PSPDF_TARGET_IOS 0

#import <Cocoa/Cocoa.h>

#define UIColor NSColor
#define UIImage NSImage
#define UIFont NSFont
#define UIBezierPath NSBezierPath
#define UIFontDescriptor NSFontDescriptor

#define UIFontDescriptorTraitsAttribute NSFontTraitsAttribute
#define UIFontDescriptorSymbolicTraits NSFontSymbolicTraits
#define UIFontDescriptorTraitBold NSFontBoldTrait
#define UIFontDescriptorTraitItalic NSFontItalicTrait
#define NSUnderlineStyle NSInteger

#define NSTextAlignmentLeft NSLeftTextAlignment
#define NSTextAlignmentRight NSRightTextAlignment
#define NSTextAlignmentCenter NSCenterTextAlignment
#define NSTextAlignmentNatural NSNaturalTextAlignment
#define NSTextAlignmentJustified NSJustifiedTextAlignment

#define NSTextAlignmentToCTTextAlignment PSPDFTextAlignmentToCTTextAlignment
PSPDF_EXTERN CTTextAlignment PSPDFTextAlignmentToCTTextAlignment(NSTextAlignment nsTextAlignment);

#define UIEdgeInsets NSEdgeInsets
#define UIEdgeInsetsZero NSEdgeInsetsZero
#define UIEdgeInsetsMake NSEdgeInsetsMake
#define UIEdgeInsetsEqualToEdgeInsets NSEdgeInsetsEqual

#define UIEdgeInsetsInsetRect PSPDFEdgeInsetInsetRect
#define UIEdgeInsetsFromString PSPDFEdgeInsetFromString
#define NSStringFromUIEdgeInsets NSStringFromPSPDFEdgeInset
PSPDF_EXTERN CGRect PSPDFEdgeInsetInsetRect(CGRect rect, UIEdgeInsets insets);
PSPDF_EXTERN NSString *NSStringFromPSPDFEdgeInset(UIEdgeInsets insets);
PSPDF_EXTERN UIEdgeInsets PSPDFEdgeInsetFromString(NSString *string);

#define NSStringFromCGPoint PSPDF_NSStringFromCGPoint
#define NSStringFromCGSize PSPDF_NSStringFromCGSize
#define NSStringFromCGRect PSPDF_NSStringFromCGRect
#define NSStringFromCGAffineTransform PSPDF_NSStringFromCGAffineTransform

PSPDF_EXTERN NSString *PSPDF_NSStringFromCGPoint(CGPoint point);
PSPDF_EXTERN NSString *PSPDF_NSStringFromCGSize(CGSize size);
PSPDF_EXTERN NSString *PSPDF_NSStringFromCGRect(CGRect rect);
PSPDF_EXTERN NSString *PSPDF_NSStringFromCGAffineTransform(CGAffineTransform transform);

#define CGPointFromString PSPDF_CGPointFromString
#define CGSizeFromString PSPDF_CGSizeFromString
#define CGRectFromString PSPDF_CGRectFromString
#define CGAffineTransformFromString PSPDF_CGAffineTransformFromString

PSPDF_EXTERN CGPoint PSPDF_CGPointFromString(NSString *string);
PSPDF_EXTERN CGSize PSPDF_CGSizeFromString(NSString *string);
PSPDF_EXTERN CGRect PSPDF_CGRectFromString(NSString *string);
PSPDF_EXTERN CGAffineTransform PSPDF_CGAffineTransformFromString(NSString *string);

#define UIApplicationDidReceiveMemoryWarningNotification PSPDFApplicationDidReceiveMemoryWarningNotification
#define UIApplicationWillEnterForegroundNotification NSApplicationWillBecomeActiveNotification
#define UIApplicationDidEnterBackgroundNotification NSApplicationDidHideNotification
#define UIApplicationWillTerminateNotification NSApplicationWillTerminateNotification
#define UIApplicationDidFinishLaunchingNotification NSApplicationDidFinishLaunchingNotification
PSPDF_EXTERN NSString *const PSPDFApplicationDidReceiveMemoryWarningNotification;

// This is implemented on PSPDFDocument, but if we ifdef there, apppledoc has parsing issues.
PSPDF_AVAILABLE_DECL @protocol UIActivityItemSource @end

#import "PSPDFMacCompatibility.h"

#else

#if !defined(TARGET_OS_TV)
#define TARGET_OS_TV 0
#endif

#define PSPDF_TARGET_MAC 0
#define PSPDF_TARGET_TV  TARGET_OS_TV
#define PSPDF_TARGET_IOS !TARGET_OS_TV

#import <UIKit/UIKit.h>

#define NSLineCapStyle CGLineCap
#define NSLineJoinStyle CGLineJoin

// Helper to get the shared application object, also for extensions.
PSPDF_EXPORT UIApplication *PSPDFSharedApplication(void);

#endif
