//
// FakeUIWebView.h
// Created by Jason Larsen on 5/8/14.
//

#import <Foundation/Foundation.h>


@interface FakeUIWebView : UIWebView
@property (nonatomic, strong) void (^loadRequestBlock)(NSURLRequest *url);
@property (nonatomic, strong) void (^loadHTMLStringBlock)(NSString *htmlString, NSURL *baseURL);
@end