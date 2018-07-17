//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface FeatureFlagsManager : NSObject <RCTBridgeModule>

@end

@implementation FeatureFlagsManager

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(syncFeatureFlags, syncFeatureFlags:(NSDictionary *) flags exemptDomains:(NSArray *)domains resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    FeatureFlags.featureFlags = flags;
    FeatureFlags.exemptDomains = domains;
    resolve(nil);
};

@end
