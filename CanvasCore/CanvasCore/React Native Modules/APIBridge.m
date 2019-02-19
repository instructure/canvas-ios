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

#import "APIBridge.h"
#import <CanvasCore/CanvasCore-Swift.h>

static APIBridge *_shared = nil;

@interface APIBridge ()

@property (nonatomic) NSMutableDictionary *requests;

@end

@implementation APIBridge

RCT_EXPORT_MODULE();

+ (instancetype)shared {
    return _shared;
}

- (id)init {
    self = [super init];
    self.requests = [NSMutableDictionary new];
    _shared = self;
    return self;
}

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }
- (NSArray<NSString *> *)supportedEvents { return @[@"APICall"]; }

- (void)call:(NSString *)name args:(NSArray *)args callback:(APIBridgeCallback)callback {
    NSString *requestID = [[NSUUID UUID] UUIDString];
    self.requests[requestID] = callback;
    NSDictionary *body = @{ @"requestID": requestID, @"name": name, @"args": args ?: @[]};
    [self sendEventWithName:@"APICall" body:body];
}

RCT_EXPORT_METHOD(requestCompleted:(NSString *)requestID result:(id)result error:(NSString *)errorString) {
    APIBridgeCallback callback = self.requests[requestID];
    if (!callback) {
        NSLog(@"APIBridge: Cannot find callback for request: %@", requestID);
        return;
    }
    
    NSError *error = nil;
    if (errorString) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorString };
        error = [NSError errorWithDomain:@"com.instructure.apibridge" code:0 userInfo:userInfo];
    }
    callback(result, error);
    self.requests[requestID] = nil;
}

@end
