//
//  PSPDFBaseConfiguration.m
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
#import "PSPDFMacros.h"
#import "PSPDFModel.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class PSPDFBaseConfigurationBuilder;

/**
 Used for various configuration options.
 @see PSPDFConfiguration
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFBaseConfiguration<BuilderType : __kindof PSPDFBaseConfigurationBuilder *> : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

+ (instancetype)defaultConfiguration;

- (instancetype)initWithBuilder:(BuilderType)builder NS_DESIGNATED_INITIALIZER;

/**
 Returns a copy of the default configuration.
 You can provide a `builderBlock` to change the value of properties.
 */
+ (instancetype)configurationWithBuilder:(nullable void (^)(BuilderType))builderBlock;

/**
 Copies an existing configuration and all settings + modifies with new changes.
 */
- (instancetype)configurationUpdatedWithBuilder:(void (^)(BuilderType))builderBlock;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFBaseConfigurationBuilder : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

@property (nonatomic, class, readonly) Class configurationTargetClass;

@property (nonatomic, readonly) __kindof PSPDFBaseConfiguration *build;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
