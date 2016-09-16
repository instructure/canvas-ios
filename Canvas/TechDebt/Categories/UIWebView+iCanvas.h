//
//  UIWebView+iCanvas.h
//  iCanvas
//
//  Created by Stephen Lottermoser on 2/1/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (iCanvas)

- (CGRect)rectForElementInWebviewWithId:(NSString *)domID;

- (void)scalePageToFit;

@end
