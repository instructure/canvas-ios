//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import "CKIClient.h"
@import WebKit;

@interface CKILoginViewController : UIViewController

@property (nonatomic, strong) WKWebView * webView;

/**
 Block to be performed when authentication is successful
 */
@property (nonatomic, copy) void (^successBlock)(NSString *oauthCode);

/**
 Block to be performed when authentication fails
 */
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

- (id)initWithRequest:(NSURLRequest *)request method:(CKIAuthenticationMethod)method;
- (void)cancelOAuth;

+ (NSString *)safariUserAgent;

+ (void)setLoadingImage:(UIImage *)image;
+ (UIImage *)loadingImage;

@end
