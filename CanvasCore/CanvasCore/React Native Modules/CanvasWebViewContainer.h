//
//  CanvasWebViewContainer.h
//  CanvasCore
//
//  Created by Nate Armstrong on 2/26/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <React/RCTView.h>

@interface CanvasWebViewContainer : RCTView

@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL hideKeyboardAccessoryView;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *error))completionHandler;

@end
