
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CBILoadingIndicator.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NSInteger const CBILoadingViewOneTagID = 100001;
NSInteger const CBILoadingViewTwoTagID = 100002;

@interface CBILoadingIndicator ()

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSArray *verticalConstraints;
@property (nonatomic, strong) NSArray *verticalTwoConstraints;
@property (nonatomic, strong) NSArray *loadingOneConstraints;
@property (nonatomic, strong) NSArray *loadingTwoConstraints;
@property (nonatomic, strong) UIView *loadingOneView;
@property (nonatomic, strong) UIView *loadingTwoView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSInteger colorIndex;

// UINavigationBarIndicator

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, assign) CGRect endFrame;

@end

@implementation CBILoadingIndicator


#pragma mark - UINavigationBar Loading Indicator

+ (CBILoadingIndicator*)indicatorForNavigationBar:(UINavigationBar *)navigationBar
{
    CBILoadingIndicator *indicator = [[CBILoadingIndicator alloc] init];
    indicator.startFrame = CGRectMake(navigationBar.frame.size.width * 0.5, navigationBar.frame.size.height - 2.0f, 0, 2.0f);
    indicator.endFrame = CGRectMake(0, navigationBar.frame.size.height - 2.0f, navigationBar.frame.size.width, 2.0f);
    indicator.navigationBar = navigationBar;
    indicator.colors = @[[UIColor blueColor], [UIColor redColor]];
    indicator.colorIndex = 0;
    return indicator;
}

- (void)showNavigationBarLoadingIndicator
{
    if (self.isLoading) {
        return;
    }
    [self setupLoadingSubviews];
    [self setIsLoading:YES];
    [self animateNewColor];
}

- (void)hideNavigationBarLoadingIndicator
{
    [self setIsLoading:NO];
}

- (void)animateNewColor
{
    UIColor *color = self.colors[self.colorIndex];
    UIView *animatingView = [self.navigationBar viewWithTag:self.colorIndex % 2 == 0 ? CBILoadingViewOneTagID : CBILoadingViewTwoTagID];
    [animatingView setBackgroundColor:color];
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
        [animatingView setFrame:self.endFrame];
    } completion:^(BOOL finished) {
        if (self.colorIndex == self.colors.count - 1) {
            self.colorIndex = 0;
        } else {
            self.colorIndex++;
        }
        
        UIView *previousAnimatingView = [self.navigationBar viewWithTag:animatingView.tag == CBILoadingViewOneTagID ? CBILoadingViewTwoTagID : CBILoadingViewOneTagID];
        [previousAnimatingView setFrame:self.startFrame];
        [self.navigationBar bringSubviewToFront:previousAnimatingView];
        
        if (self.isLoading) {
            [self animateNewColor];
        } else {
            [self animateOut];
        }
    }];
    
}

- (void)animateOut
{
    UIView *animatingView = [self.navigationBar viewWithTag:self.colorIndex % 2 == 0 ? CBILoadingViewOneTagID : CBILoadingViewTwoTagID];
    UIView *previouslyAnimatedView = [self.navigationBar viewWithTag:self.colorIndex % 2 == 0 ? CBILoadingViewTwoTagID : CBILoadingViewOneTagID];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, animatingView.frame.origin.y, self.endFrame.size.width * 0.5, animatingView.frame.size.height)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.endFrame.size.width * 0.5, animatingView.frame.origin.y, self.endFrame.size.width * 0.5, animatingView.frame.size.height)];
    
    [leftView setBackgroundColor:previouslyAnimatedView.backgroundColor];
    [rightView setBackgroundColor:previouslyAnimatedView.backgroundColor];
    
    [self.navigationBar addSubview:leftView];
    [self.navigationBar addSubview:rightView];
    
    [animatingView removeFromSuperview];
    [previouslyAnimatedView removeFromSuperview];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [leftView setFrame:CGRectMake(0, leftView.frame.origin.y, 0, leftView.frame.size.height)];
        [rightView setFrame:CGRectMake(self.navigationBar.frame.size.width, rightView.frame.origin.y, 0, rightView.frame.size.height)];
    } completion:nil];
}

- (void)setupLoadingSubviews
{
    UIView *viewOne;
    UIView *viewTwo;
    for (UIView *subview in [self.navigationBar subviews])
    {
        if (subview.tag == CBILoadingViewOneTagID)
        {
            viewOne = subview;
        }
        if (subview.tag == CBILoadingViewTwoTagID) {
            viewTwo = subview;
        }
    }
    
    if(!viewOne) {
        viewOne = [[UIView alloc] initWithFrame:self.startFrame];
        viewOne.tag = CBILoadingViewOneTagID;
        viewOne.backgroundColor = [UIColor blueColor];
        [self.navigationBar addSubview:viewOne];
    } else {
        viewOne.frame = self.startFrame;
    }
    
    if (!viewTwo) {
        viewTwo = [[UIView alloc] initWithFrame:self.startFrame];
        viewTwo.tag = CBILoadingViewTwoTagID;
        viewTwo.backgroundColor = [UIColor redColor];
        [self.navigationBar addSubview:viewTwo];
        
    } else {
        viewTwo.frame = self.startFrame;
    }
}

- (id)initWithViewController:(UIViewController *)controller colorArray:(NSArray *)colorsArray
{
    if (self == [super init]) {
        
        self.viewController = controller;
        self.colors = colorsArray;
        
        if (! self.colors) {
            self.colors = @[[UIColor blueColor], [UIColor greenColor]];
        }
        
        
        UIView *loadingView = [[UIView alloc] init];
        [loadingView setBackgroundColor:self.colors[0]];
        
        [controller.view addSubview:loadingView];
        [loadingView setTag:1000];
        [loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
        id topLayoutGuide = controller.topLayoutGuide;
        self.verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-0-[loadingView(2)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topLayoutGuide, loadingView)];
        float width = self.viewController.view.frame.size.width;
        self.loadingOneConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[loadingView(0)]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(loadingView)];
        [controller.view addConstraints:self.verticalConstraints];
        [controller.view addConstraints:self.loadingOneConstraints];
        self.loadingOneView = loadingView;
        
        
        UIView *loadingTwo = [[UIView alloc] init];
        [controller.view addSubview:loadingTwo];
        [loadingTwo setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.verticalTwoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-0-[loadingTwo(2)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topLayoutGuide, loadingTwo)];
        self.loadingTwoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[loadingTwo(0)]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(loadingTwo)];
        [controller.view addConstraints:self.loadingTwoConstraints];
        [controller.view addConstraints:self.verticalTwoConstraints];
        
        self.loadingTwoView = loadingTwo;
        [self setColorIndex:0];
    }
    
    return self;
}

- (void)showLoadingBar
{
    [self setIsLoading:YES];
    [self animateNewColor:self.loadingOneView];
}

- (void)hideLoadingBar
{
    [self setIsLoading:NO];
}

- (void)animateNewColor:(UIView *)view
{
    
    [view setBackgroundColor:self.colors[self.colorIndex]];
    self.colorIndex = (self.colorIndex + 1 <  self.colors.count) ? self.colorIndex + 1 : 0;
    
    if (! [self isLoading]) {
        UIView *endView = nil;
        if (view == self.loadingOneView) {
            endView = self.loadingTwoView;
            [self.viewController.view removeConstraints:self.loadingTwoConstraints];
            float width = self.viewController.view.frame.size.width;
            self.loadingTwoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[endView]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(endView)];
        } else {
            endView = self.loadingOneView;
            [self.viewController.view removeConstraints:self.loadingOneConstraints];
            float width = self.viewController.view.frame.size.width;
            self.loadingOneConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[endView]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(endView)];
        }
        
        [UIView animateWithDuration:0.6f animations:^{
            if (view == self.loadingOneView) {
                [self.viewController.view addConstraints:self.loadingTwoConstraints];
            } else {
                [self.viewController.view addConstraints:self.loadingOneConstraints];
            }
            [self.viewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        return;
    }
    
    NSArray *constraints = nil;
    if (view == self.loadingOneView) {
        constraints = self.loadingOneConstraints;
    } else {
        constraints = self.loadingTwoConstraints;
    }
    
    [UIView animateWithDuration:0.4f animations:^{
        [self.viewController.view removeConstraints:constraints];
        
        if (view == self.loadingOneView) {
            self.loadingOneConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
            [self.viewController.view addConstraints:self.loadingOneConstraints];
        } else {
            self.loadingTwoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
            [self.viewController.view addConstraints:self.loadingTwoConstraints];
        }
        [self.viewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        UIView *nextView = nil;
        NSArray *nextConstraints = nil;
        if (view == self.loadingOneView) {
            nextView = self.loadingTwoView;
            nextConstraints = self.loadingTwoConstraints;
            [self.viewController.view removeConstraints:nextConstraints];
            float width = self.viewController.view.frame.size.width;
            self.loadingTwoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[nextView(0)]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(nextView)];
            [self.viewController.view addConstraints:self.loadingTwoConstraints];
            [self.viewController.view bringSubviewToFront:nextView];
            [self.viewController.view layoutIfNeeded];
        } else {
            nextView = self.loadingOneView;
            nextConstraints = self.loadingOneConstraints;
            [self.viewController.view removeConstraints:nextConstraints];
            float width = self.viewController.view.frame.size.width;
            self.loadingOneConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[nextView(0)]-%f-|", width * 0.5, width * 0.5] options:0 metrics:nil views:NSDictionaryOfVariableBindings(nextView)];
            [self.viewController.view addConstraints:self.loadingOneConstraints];
            [self.viewController.view bringSubviewToFront:nextView];
            [self.viewController.view layoutIfNeeded];
        }
        
        [self performSelector:@selector(animateNewColor:) withObject:nextView afterDelay:1.0f];
    }];
    
}



@end
