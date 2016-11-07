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
#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaRefreshControl : CSGFlyingPandaAnimationView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

- (void)setTarget:(id)target action:(SEL)action;

//! Call these in the associated delegate methods in the scrollView.
- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

//! Use this to kick off a refresh/loading programmatically only. It will call the action established
//! in the initializer immediately, and adjust the contentInset of the scrollView accordingly.
//!
//! @parem: invokeTarget: should the default refresh be called
- (void)startLoading:(BOOL)invokeTarget;

// Call this whenever the data has been fetched and the refresh animation should be done.
- (void)finishLoading;

- (void)finishLoadingWithCompletion:(void (^)()) completion;

//! Call this if the panda animation shouldn't be showing be default. I.e. it won't be showing
//! unless the user pulls to refresh.
- (void)setToIdle;

- (void)updateFrame;

@property (nonatomic, assign) CGFloat originalTopContentInset;

@end
