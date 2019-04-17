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
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface LocalizationManagerReact : NSObject<RCTBridgeModule>

@end

@implementation LocalizationManagerReact

RCT_EXPORT_MODULE(LocalizationManager);

RCT_EXPORT_METHOD(setCurrentLocale:(NSString * _Nonnull)locale) {
    [LocalizationManager setCurrentLocale:locale];
}

RCT_REMAP_METHOD(getLocales, getLocalesResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([LocalizationManager getLocales]);
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
