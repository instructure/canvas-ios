//
// Copyright (C) 2016-present Instructure, Inc.
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
#import "CKCanvasURLConnection.h"
#import "CKCanvasAPI.h"

extern NSString * const CKAPIHTTPMethodKey;
extern NSString * const CKAPINoAccessTokenRequired;
extern NSString *const CKAPIIncludePermissionsKey;
extern NSString *const CKAPINoMasqueradeIDRequired;

typedef id (^CKInfoToObjectMappingBlock)(NSDictionary *info);

@interface CKCanvasAPI (Private)

- (CKCanvasURLConnection *)runForURL:(NSURL *)url options:(NSDictionary *)options block:(CKHTTPURLConnectionDoneCB)block;
- (void)_uploadFiles:(NSArray *)fileURLs toEndpoint:(NSURL *)endpoint progressBlock:(void (^)(float))progressBlock completionBlock:(CKArrayBlock)completionBlock;

- (void)runForPaginatedURL:(NSURL *)url withMapping:(CKInfoToObjectMappingBlock)mapping completion:(CKPagedArrayBlock)completion;

@end
