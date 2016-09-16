//
//  CKOAuthWebLoginViewController.h
//  CanvasKit
//
//  Created by Stephen Lottermoser on 11/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKCanvasAPI, CKUser;

@interface CKOAuthWebLoginViewController : UIViewController <UIWebViewDelegate>

@property (copy) void (^finishedBlock)(NSError *error, NSString *accessToken, CKUser *user);

@property (weak) IBOutlet UIWebView *webView;

@property BOOL forceCanvasLogin;

@property (copy) NSURL *baseURL;
@property (copy) NSString *clientID;
@property (copy) NSString *clientSecret;

@property (copy, readonly) NSString *accessToken;
@property (strong, readonly) CKUser *user;

@property (weak) CKCanvasAPI *canvasAPI;

@end
