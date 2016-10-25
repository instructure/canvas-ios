//
//  PSPDFMacros.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

// Wraps C function to prevent the C++ compiler to mangle C function names.
// https://stackoverflow.com/questions/1041866/in-c-source-what-is-the-effect-of-extern-c

/// Callable from 3rd party. 
#if defined(__cplusplus)
#define PSPDF_EXPORT extern "C" __attribute__((visibility("default")))
#else
#define PSPDF_EXPORT extern __attribute__((visibility("default")))
#endif

/// Callable from inside the framework.
#define PSPDF_EXTERN FOUNDATION_EXTERN

#define PSPDF_CLASS_AVAILABLE __attribute__((visibility("default")))
#define PSPDF_ENUM_AVAILABLE
#define PSPDF_AVAILABLE_DECL

// Subclassing control
#define PSPDF_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))
#define PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED PSPDF_CLASS_AVAILABLE PSPDF_SUBCLASSING_RESTRICTED

// Equivalent to Swift's @noescape
#define PSPDF_NOESCAPE __attribute__((noescape))

// Deprecation helper
#define PSPDF_DEPRECATED(version, msg) __attribute__((deprecated("Deprecated in PSPDFKit " #version ". " msg)))

#import "PSPDFEnvironment.h"

// API Unavailability
// Declares the parameterless `-init` and `+new` as unavailable.
#ifndef PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE
#define PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE \
__attribute__((unavailable("Not the designated initializer")))
#endif // PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE

#define PSPDF_EMPTY_INIT_UNAVAILABLE \
- (instancetype)init PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE; \
+ (instancetype)new PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;

#define PSPDF_INIT_WITH_CODER_UNAVAILABLE - (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;

#define PSPDF_DEFAULT_VIEW_INIT_UNAVAILABLE \
PSPDF_EMPTY_INIT_UNAVAILABLE \
PSPDF_INIT_WITH_CODER_UNAVAILABLE \
- (instancetype)initWithFrame:(CGRect)frame PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE; \

#define PSPDF_DEFAULT_VIEWCONTROLLER_INIT_UNAVAILABLE \
PSPDF_EMPTY_INIT_UNAVAILABLE \
PSPDF_INIT_WITH_CODER_UNAVAILABLE \
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;

#define PSPDF_DEFAULT_TABLEVIEWCONTROLLER_INIT_UNAVAILABLE \
PSPDF_DEFAULT_VIEWCONTROLLER_INIT_UNAVAILABLE \
- (instancetype)initWithStyle:(UITableViewStyle)style PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;
