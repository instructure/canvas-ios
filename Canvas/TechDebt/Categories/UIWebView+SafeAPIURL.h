//
//  UIWebView+SafeAPIURL.h
//  iCanvas
//
//  Created by nlambson on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (SafeAPIURL)
-(void)replaceHREFsWithAPISafeURLs;
@end
