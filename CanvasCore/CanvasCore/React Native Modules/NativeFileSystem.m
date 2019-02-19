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
#import <UIKit/UIKit.h>

@interface NativeFileSystem: NSObject<RCTBridgeModule>

@end

@implementation NativeFileSystem

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_REMAP_METHOD(pathForResource, named:(NSString *)name ofType:(NSString *)type resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.instructure.CanvasCore"] pathForResource:name ofType:type];
    resolve(path);
}

RCT_REMAP_METHOD(convertToJPEG, path:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSURL *inputURL = [NSURL URLWithString:path];
    UIImage *image = [UIImage imageWithContentsOfFile:inputURL.path];
    if (!image) { reject(@"0", NSLocalizedString(@"Failed to find image at path", comment: nil), nil); }
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    NSURL *tmp = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *url = [[tmp URLByAppendingPathComponent:[inputURL URLByDeletingPathExtension].lastPathComponent] URLByAppendingPathExtension:@"jpg"];
    BOOL success = [data writeToURL:url atomically:YES];
    if (success) {
        resolve(url.absoluteString);
    } else {
        reject(@"1", NSLocalizedString(@"Failed to write image", comment: nil), nil);
    }
}

@end
