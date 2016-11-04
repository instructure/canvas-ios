
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
    
    

#import "PandaTableView.h"
#import "CSGFlyingPandaRefreshControl.h"

@interface PandaTableView ()

@property (nonatomic, retain) CSGFlyingPandaRefreshControl *pandaRefreshControl;

@end

@implementation PandaTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style target:(id)target action:(SEL)action topLayoutGuideConstant:(CGFloat)topLayout {
    self = [super initWithFrame:frame style:style];
    if(self) {
        [self commonInitWithTarget:target action:action];
        self.pandaRefreshControl.originalTopContentInset = topLayout;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style target:(id)target action:(SEL)action{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self commonInitWithTarget:target action:action];
    }
    return self;
}

-(void)commonInitWithTarget:(id)target action:(SEL)action {
    [self.panGestureRecognizer addTarget:self action:@selector(panned:)];
//    self.pandaRefreshControl = [[CSGFlyingPandaRefreshControl alloc] initWithScrollView:self target:target action:action];
    [self addSubview:self.pandaRefreshControl];
}

-(void)setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
    [self.pandaRefreshControl scrollViewDidScroll];
}

-(void)panned:(UIPanGestureRecognizer*) recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.pandaRefreshControl scrollViewDidEndDragging];
    }
}

-(void)startLoadingAndInvokeTarget:(BOOL)invokeTarget{
    [self.pandaRefreshControl startLoading:invokeTarget];
}

-(void)stopLoadingWithCompletion:(void (^)())completion {
    [self.pandaRefreshControl finishLoadingWithCompletion:completion];
}

-(void)stopLoading {
    [self.pandaRefreshControl finishLoading];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.pandaRefreshControl updateFrame];
}

/**
 If you load the PandaTableView on a non-displayed viewController vs a displayed viewController there
 is some content inset change that happens under the hood. To deal with
 this, Ben put a method in PandaRefreshControl:startLoading, to specifically test for
 this case. However if you load on a non-displayed controller, you want to skip that test case. In order
 to do so, just call this method on creation.
 */
-(void)setToIdle{
    [self.pandaRefreshControl setToIdle];
}

@end
