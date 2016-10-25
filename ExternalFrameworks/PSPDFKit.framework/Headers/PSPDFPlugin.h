//
//  PSPDFPlugin.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_EXPORT const NSUInteger PSPDFPluginProtocolVersion_1;

PSPDF_EXPORT NSString *const PSPDFPluginIdentifierKey;
PSPDF_EXPORT NSString *const PSPDFPluginNameKey;
PSPDF_EXPORT NSString *const PSPDFPluginEnabledKey;
PSPDF_EXPORT NSString *const PSPDFPluginPriorityKey;
PSPDF_EXPORT NSString *const PSPDFPluginInitializeOnDiscoveryKey;
PSPDF_EXPORT NSString *const PSPDFPluginSaveInstanceKey;
PSPDF_EXPORT NSString *const PSPDFPluginProtocolVersionKey;

PSPDF_AVAILABLE_DECL @protocol PSPDFPlugin <NSObject>

/// Designated initializer. Will be called upon creation.
/// For potential `options` see constants named `PSPDFPlugin*`.
- (instancetype)initWithPluginRegistry:(id)pluginRegistry options:(nullable NSDictionary<NSString *, id> *)options;

/// Plugin details for auto-discovery.
+ (NSDictionary<NSString *, id> *)pluginInfo;

@end

NS_ASSUME_NONNULL_END
