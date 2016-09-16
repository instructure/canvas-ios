//
//  CKCanvasAPIPrivate.h
//  CanvasKit
//
//  Created by Joshua Dutton on 5/30/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
