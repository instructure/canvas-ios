//
//  UIWebView+SafeAPIURL.m
//  iCanvas
//
//  Created by nlambson on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "UIWebView+SafeAPIURL.h"

@implementation UIWebView (SafeAPIURL)
-(void)replaceHREFsWithAPISafeURLs
{
    [self stringByEvaluatingJavaScriptFromString:@"var links = document.getElementsByTagName('a'); for (var i = 0; i < links.length; i++){ if(links[i].getAttribute('data-api-endpoint')){ links[i].setAttribute('href',links[i].getAttribute('data-api-endpoint'));}}"];
}
@end
