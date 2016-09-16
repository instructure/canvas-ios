//
//  CKOAuthController.h
//  CanvasKit
//
//  Created by BJ Homer on 8/4/11.
//  Copyright 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKCanvasAPI, CKUser;

@interface CKOAuthController : UIViewController
<UIWebViewDelegate, UITextFieldDelegate> 

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectBottomConstraint;
@property (copy) void (^finishedBlock)(NSError *error, NSString *accessToken, CKUser *user);
@property (weak) CKCanvasAPI *canvasAPI;

- (void)doLoginForDomain:(NSString *)domain; // `domain` should look like 'example.instructure.com'

@end
