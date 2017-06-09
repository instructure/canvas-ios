//
//  PSPDFVersion.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
#error PSPDFKit 6 supports iOS 9.0 upwards.
#endif

/// Xcode 8.0 is required for PSPDFKit 6.
#if !defined(__IPHONE_10_0) && !defined(__MAC_10_12)
#warning PSPDFKit 6 has been designed for Xcode 8 with SDK 10. Other combinations are not supported.
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-id-macro"

#define __PSPDFKIT_IOS__
#define __PSPDFKIT_3_0 30000
#define __PSPDFKIT_3_1 30100
#define __PSPDFKIT_3_2 30200 // 3.2 is the last version supporting iOS 5.
#define __PSPDFKIT_3_3 30300
#define __PSPDFKIT_3_4 30400
#define __PSPDFKIT_3_5 30500
#define __PSPDFKIT_3_6 30600
#define __PSPDFKIT_3_7 30700 // 3.7 is the last version supporting iOS 6.
#define __PSPDFKIT_4_0 40000
#define __PSPDFKIT_4_1 40100
#define __PSPDFKIT_4_2 40200
#define __PSPDFKIT_4_3 40300
#define __PSPDFKIT_4_4 40400 // 4.4 is the last version supporting iOS 7.
#define __PSPDFKIT_5_0 50000
#define __PSPDFKIT_5_1 50100
#define __PSPDFKIT_5_2 50200
#define __PSPDFKIT_5_3 50300
#define __PSPDFKIT_5_4 50400
#define __PSPDFKIT_5_5 50500 // 5.5 is the last version supporting iOS 8.
#define __PSPDFKIT_6_0 60000
#define __PSPDFKIT_6_1 60100
#define __PSPDFKIT_6_2 60200
#define __PSPDFKIT_6_3 60300
#define __PSPDFKIT_6_4 60400
#define __PSPDFKIT_6_5 60500
#define __PSPDFKIT_6_6 60600
#define __PSPDFKIT_6_7 60700

#pragma clang diagnostic pop
