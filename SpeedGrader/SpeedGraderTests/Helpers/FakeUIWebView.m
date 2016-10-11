//
// FakeUIWebView.m
// Created by Jason Larsen on 5/8/14.
//

#import "FakeUIWebView.h"

@interface FakeUIWebView ()

@end

@implementation FakeUIWebView

- (void)loadRequest:(NSURLRequest *)request
{
    if (self.loadRequestBlock) {
        self.loadRequestBlock(request);
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (self.loadHTMLStringBlock) {
        self.loadHTMLStringBlock(string, baseURL);
    }
}

@end