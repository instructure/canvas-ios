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