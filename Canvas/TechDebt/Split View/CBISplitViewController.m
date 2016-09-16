//
//  CBISplitViewController.m
//  iCanvas
//
//  Created by derrick on 10/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBISplitViewController.h"
#import "CBISplitSeparatorView.h"
#import "CBISplitTransitionShadowView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
@import ReactiveCocoa;
@import MyLittleViewController;
@import SoPretty;

static const CGFloat CBISplitViewControllerMasterWidth = 320.f;
static const NSTimeInterval CBISplitPushPopDuration = 0.25;
static const NSTimeInterval CBISplitPushPopMostOfTheRelativeDuration = 0.8;
static const NSTimeInterval CBISplitPushPopTheRestOfTheRelativeDuration = 1.0 - CBISplitPushPopMostOfTheRelativeDuration;


@interface CBISplitPushTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface CBISplitPopTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, copy) void (^completeTransitionBlock)(BOOL);
@end


@interface CBISplitViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>
@property (nonatomic) UIView *masterContainerView, *detailContainerView;
@property (nonatomic) UINavigationBar *masterSubNavBar, *detailSubNavBar;
@property (nonatomic) CBISplitSeparatorView *separatorView;
@property (nonatomic) CBISplitTransitionShadowView *shadowView;
@property (nonatomic, readwrite) NSLayoutConstraint *masterWidthConstraint, *masterXOffsetConstraint, *detailWidthConstraint, *detailXOffsetConstraint;

@property (nonatomic) UIScreenEdgePanGestureRecognizer *popGestureRecognizer;
@property (nonatomic) id<UIViewControllerAnimatedTransitioning> animatedTransition;
@property (nonatomic) UIPercentDrivenInteractiveTransition *popTransition;
@end

@implementation CBISplitViewController

+ (void)initialize
{
    UINavigationBar *proxy = [UINavigationBar appearanceWhenContainedIn:self, nil];
    proxy.barTintColor = [UIColor prettyLightGray];
    proxy.tintColor = Brand.current.tintColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self constrainDetailViewControllerWidth];
    
    self.navigationController.delegate = nil;
    [self prepareCustomTransitioning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self constrainDetailViewControllerWidth];

    self.master.view.frame = self.masterContainerView.bounds;
}

- (void)pushNextDetailViewController:(UIViewController *)nextDetailViewController animated:(BOOL)animated
{
    CBISplitViewController *nextSplit = [CBISplitViewController new];
    nextSplit.isDetailToMasterTransition = YES;
    nextSplit.detail = nextDetailViewController;
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:nextSplit animated:animated];
}

- (void)prepareCustomTransitioning {
    NSUInteger vcCount = self.navigationController.viewControllers.count;
    if (vcCount <= 1) {
        return;
    }
    
    if (!self.isDetailToMasterTransition) {
        return;
    }
    
    self.navigationController.delegate = self;
    
    [self prepareInteractivePopGesture];
}

- (void)constrainDetailViewControllerWidth
{
    self.detailWidthConstraint.constant = self.view.bounds.size.width - self.masterWidthConstraint.constant;
    [self.detailWidthConstraint.firstItem layoutIfNeeded];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self constrainDetailViewControllerWidth];
}

- (void)prepareInteractivePopGesture
{
    if (!self.navigationController || self.popGestureRecognizer) {
        return;
    }
    
    self.popGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(poppingWithGestureRecognizer:)];
    self.popGestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:self.popGestureRecognizer];
}

- (void)forceInteractiveTransitionToFinish
{
    double delayInSeconds = CBISplitPushPopDuration / 2.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CBISplitPopTransitioning *pop = (CBISplitPopTransitioning *)self.animatedTransition;
        if (pop.completeTransitionBlock){
            pop.completeTransitionBlock(YES);
            pop.completeTransitionBlock = nil;
        }
    });
}

- (void)poppingWithGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)popGesture
{
    if (popGesture.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.popTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    CGFloat progress = [popGesture translationInView:self.view].x / ([self.animatedTransition isKindOfClass:[CBISplitPopTransitioning class]] ? self.masterWidthConstraint.constant : self.view.bounds.size.width);
    // see comment here: http://stackoverflow.com/a/19133416/1518561 about the animation completion block not being called
    progress = MIN(0.99, MAX(0.01, progress));
    NSLog(@"progress=%.2f", progress);
    CGFloat velocity = [popGesture velocityInView:self.view].x;

    if (popGesture.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.popTransition updateInteractiveTransition:progress];
    } else if (popGesture.state == UIGestureRecognizerStateEnded || popGesture.state == UIGestureRecognizerStateCancelled) {
        
        // Finish or cancel the interactive transition
        if (velocity > 0 && progress > 0.1) {
            [self.popTransition finishInteractiveTransition];
        }
        else {
            [self.popTransition cancelInteractiveTransition];
        }

        [self forceInteractiveTransitionToFinish];
        self.popTransition = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.master.automaticallyAdjustsScrollViewInsets = NO;
    self.detail.automaticallyAdjustsScrollViewInsets = NO;

    // force the detail view to load in case it's not available instantly
    self.detailContainerView.backgroundColor = [UIColor whiteColor];
    
    RAC(self, navigationItem.rightBarButtonItem) = RACObserve(self, detail.navigationItem.rightBarButtonItem);
    RAC(self, title) = RACObserve(self, master.title);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)prepareMasterAndDetail
{
    const CGRect bounds = self.view.bounds;
    _masterContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CBISplitViewControllerMasterWidth, bounds.size.height)];
    _masterContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_masterContainerView];
    
    _detailContainerView = [[UIView alloc] initWithFrame:CGRectMake(CBISplitViewControllerMasterWidth, 0, bounds.size.width - CBISplitViewControllerMasterWidth, bounds.size.height)];
    _detailContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_detailContainerView];
    
    _shadowView = [CBISplitTransitionShadowView new];
    _shadowView.alpha = 0.0;
    [self.view addSubview:_shadowView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shadowView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_shadowView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_shadowView(8)][_detailContainerView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_shadowView, _detailContainerView)]];
    
    _separatorView = [[CBISplitSeparatorView alloc] init];
    [self.view addSubview:_separatorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_separatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_separatorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_separatorView(1)][_detailContainerView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_separatorView, _detailContainerView)]];
    
    self.masterXOffsetConstraint = [NSLayoutConstraint constraintWithItem:_masterContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:self.masterXOffsetConstraint];
    self.masterWidthConstraint = [NSLayoutConstraint constraintWithItem:_masterContainerView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:CBISplitViewControllerMasterWidth];
    [_masterContainerView addConstraint:self.masterWidthConstraint];
    
    self.detailWidthConstraint = [NSLayoutConstraint constraintWithItem:_detailContainerView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:724];
    [_detailContainerView addConstraint:self.detailWidthConstraint];
    
    self.detailXOffsetConstraint = [NSLayoutConstraint constraintWithItem:_detailContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:CBISplitViewControllerMasterWidth];
    [self.view addConstraint:self.detailXOffsetConstraint];

    id topLayoutGuide = self.topLayoutGuide;
    id bottomLayoutGuide = self.bottomLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][_masterContainerView][bottomLayoutGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topLayoutGuide, _masterContainerView, bottomLayoutGuide)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][_detailContainerView][bottomLayoutGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topLayoutGuide, _detailContainerView, bottomLayoutGuide)]];
}

- (UIView *)masterContainerView
{
    if (_masterContainerView) {
        return _masterContainerView;
    }
    
    [self prepareMasterAndDetail];
    return _masterContainerView;
}

- (UIView *)detailContainerView
{
    if (_detailContainerView) {
        return _detailContainerView;
    }
    
    [self prepareMasterAndDetail];
    return _detailContainerView;
}

- (void)setMaster:(UIViewController *)master
{
    if (_master) {
        [_master willMoveToParentViewController:nil];
        [_master.view removeFromSuperview];
        [_master removeFromParentViewController];
    }
    
    _master = master;
    
    if (_master) {
        [self addChildViewController:_master];
        CGFloat height = self.view.bounds.size.height;
        _master.view.frame = CGRectMake(0, 0, CBISplitViewControllerMasterWidth, height);
        _master.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([_master isKindOfClass:[UITableViewController class]]) {
            ((UITableViewController *) _master).clearsSelectionOnViewWillAppear = NO;
        }
        [self.masterContainerView addSubview:_master.view];
        [_master didMoveToParentViewController:self];
    }
}

- (void)setDetail:(UIViewController *)detail
{
    if (_detail) {
        [_detail willMoveToParentViewController:nil];
        [_detail.view removeFromSuperview];
        [_detail removeFromParentViewController];
    }
    
    _detail = detail;
    
    if (_detail) {
        [self addChildViewController:_detail];
        _detail.view.frame = self.detailContainerView.bounds;
        _detail.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([_detail isKindOfClass:[UITableViewController class]]) {
            UITableViewController *controller = (UITableViewController *)_detail;
            controller.clearsSelectionOnViewWillAppear = YES;
            [controller.tableView deselectRowAtIndexPath:controller.tableView.indexPathForSelectedRow animated:YES];
        }
        [self.detailContainerView addSubview:_detail.view];
        [_detail didMoveToParentViewController:self];

        // fix for refresh control not visible when initially refreshing tableviews appear
        UIScrollView *scrollView = (UIScrollView *)_detail.view;
        if ([scrollView isKindOfClass:[UIScrollView class]] && scrollView.contentOffset.y <= 0.0 && scrollView.contentOffset.y > -124.0) {
            UIEdgeInsets insets = scrollView.contentInset;
            scrollView.contentOffset = CGPointMake(0, -insets.top);
        }

    }
}

- (void)layoutMasterAndDetailViews
{
    [self.detailContainerView layoutIfNeeded];
    [self.masterContainerView layoutIfNeeded];
    [self.separatorView layoutIfNeeded];
    [self.shadowView layoutIfNeeded];
}


#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[CBISplitViewController class]] && [(CBISplitViewController *)toVC isDetailToMasterTransition]) {
        self.animatedTransition = [CBISplitPushTransitioning new];
    } else if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[CBISplitViewController class]]) {
        self.animatedTransition = [CBISplitPopTransitioning new];
    } else {
        self.animatedTransition = nil;
    }
    return self.animatedTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.popTransition;
}

@end


#pragma mark - push animated transisition
@implementation CBISplitPushTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return CBISplitPushPopDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CBISplitViewController *bottom = (CBISplitViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CBISplitViewController *top = (CBISplitViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    NSAssert([bottom isKindOfClass:[CBISplitViewController class]] && [top isKindOfClass:[CBISplitViewController class]], @"source and destination must both be split");
    
    top.view.frame = CGRectOffset(bottom.view.frame, bottom.view.frame.size.width, 0);
    bottom.shadowView.alpha = 0.0;
    top.detailXOffsetConstraint.constant = 0.0;
    CGRect bottomViewFrame = bottom.view.frame;
    [[transitionContext containerView] insertSubview:top.view aboveSubview:bottom.view];
    [top layoutMasterAndDetailViews];
    [UIView animateKeyframesWithDuration:CBISplitPushPopDuration delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:CBISplitPushPopTheRestOfTheRelativeDuration animations:^{
            bottom.shadowView.alpha = 1.0;
            bottom.masterXOffsetConstraint.constant = CBISplitPushPopTheRestOfTheRelativeDuration * -bottom.masterWidthConstraint.constant/2.f;
            bottom.detailXOffsetConstraint.constant = CBISplitPushPopMostOfTheRelativeDuration * bottom.detailXOffsetConstraint.constant;
            bottom.detailWidthConstraint.constant = bottom.masterWidthConstraint.constant + CBISplitPushPopMostOfTheRelativeDuration * (bottom.detailWidthConstraint.constant - bottom.masterWidthConstraint.constant);
            [bottom layoutMasterAndDetailViews];
            CGRect topViewKeyframe = bottomViewFrame;
            topViewKeyframe.origin.x = bottom.detailXOffsetConstraint.constant + bottom.detailWidthConstraint.constant;
            top.view.frame = topViewKeyframe;
        }];
        [UIView addKeyframeWithRelativeStartTime:CBISplitPushPopTheRestOfTheRelativeDuration relativeDuration:CBISplitPushPopMostOfTheRelativeDuration animations:^{
            bottom.masterXOffsetConstraint.constant = -bottom.masterWidthConstraint.constant/2.f;
            bottom.detailXOffsetConstraint.constant = 0.0;
            bottom.detailWidthConstraint.constant = bottom.masterWidthConstraint.constant;
            [bottom layoutMasterAndDetailViews];
            top.view.frame = CGRectOffset(bottomViewFrame, bottom.masterWidthConstraint.constant, 0);
        }];
    } completion:^(BOOL finished) {
        top.view.frame = bottom.view.frame;
        UIViewController *newMaster = bottom.detail;
        top.master = newMaster;
        top.detailXOffsetConstraint.constant = top.masterWidthConstraint.constant;
        
        [bottom.view removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        top.animatedTransition = nil;
    }];
}

@end

#pragma mark - pop animated transition
@implementation CBISplitPopTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return CBISplitPushPopDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    __weak CBISplitViewController *top = (CBISplitViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __weak CBISplitViewController *bottom = (CBISplitViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    NSAssert([top isKindOfClass:[CBISplitViewController class]] && [bottom isKindOfClass:[CBISplitViewController class]], @"source and destination must both be split");
    
    [[transitionContext containerView] insertSubview:bottom.view belowSubview:top.view];
    bottom.detail = top.master;
    top.view.frame = CGRectOffset(bottom.view.frame, top.masterWidthConstraint.constant, 0);
    top.detailXOffsetConstraint.constant = 0.0;
    bottom.masterXOffsetConstraint.constant = -bottom.masterWidthConstraint.constant/2.f;
    bottom.detailXOffsetConstraint.constant = 0.0;
    bottom.detailWidthConstraint.constant = bottom.masterWidthConstraint.constant;
    bottom.shadowView.alpha = 1.0;
    [top layoutMasterAndDetailViews];
    [bottom layoutMasterAndDetailViews];
    
    
    // Animation code that had to be commented out for now. It was causing some issues with the split view controllers not being destroyed.
    // Will will want to re visit this code and fix the root cause of the issue.
//    // This is a hack... keeping the completion block arround so that when the
//    // completion block is not called by UIKit as it is supposed to be... I
//    // can call it manually and prevent the UI from locking up.
//    __block BOOL transitionCompleted = NO;
//    self.completeTransitionBlock = ^(BOOL finished) {
//        if (transitionCompleted) {
//            return;
//        }
//        transitionCompleted = YES;
//        
//        if (!transitionContext.transitionWasCancelled) {
//            if ([bottom.detail isKindOfClass:[UITableViewController class]]) {
//                UITableView *table = ((UITableViewController *)bottom.detail).tableView;
//                [table deselectRowAtIndexPath:table.indexPathForSelectedRow animated:YES];
//            }
//            [top.view removeFromSuperview];
//            if ((id<UINavigationControllerDelegate>)top == bottom.navigationController.delegate) {
//                bottom.navigationController.delegate = nil;
//            }
//        } else {
//            [bottom.view removeFromSuperview];
//            top.master = bottom.detail;
//            top.view.frame = bottom.view.frame;
//            top.detailXOffsetConstraint.constant = top.masterWidthConstraint.constant;
//            // setting the frame manually since the constraint isn't being respected in some cases.
//            CGRect detailFrame = top.detailContainerView.frame;
//            detailFrame.origin.x = top.masterWidthConstraint.constant;
//            top.detailContainerView.frame = detailFrame;
//            [top.detailContainerView layoutIfNeeded];
//            bottom.shadowView.alpha = 0.0;
//            [top layoutMasterAndDetailViews];
//        }
//        
//        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//        top.animatedTransition = nil;
//    };
    
    [UIView animateKeyframesWithDuration:CBISplitPushPopDuration delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:CBISplitPushPopMostOfTheRelativeDuration animations:^{
            top.view.frame = CGRectOffset(bottom.view.frame, bottom.view.frame.size.width * CBISplitPushPopMostOfTheRelativeDuration, 0);
            bottom.detailXOffsetConstraint.constant = CBISplitPushPopMostOfTheRelativeDuration * bottom.masterWidthConstraint.constant;
            bottom.detailWidthConstraint.constant = CBISplitPushPopMostOfTheRelativeDuration * (bottom.view.frame.size.width - bottom.masterWidthConstraint.constant);
            bottom.masterXOffsetConstraint.constant = (1.0 - CBISplitPushPopMostOfTheRelativeDuration) * bottom.masterXOffsetConstraint.constant;
            [bottom layoutMasterAndDetailViews];
        }];
        [UIView addKeyframeWithRelativeStartTime:CBISplitPushPopMostOfTheRelativeDuration relativeDuration:CBISplitPushPopTheRestOfTheRelativeDuration animations:^{
            bottom.shadowView.alpha = 0.0;
            top.view.frame = CGRectOffset(bottom.view.frame, bottom.view.frame.size.width, 0);
            bottom.detailXOffsetConstraint.constant = bottom.masterWidthConstraint.constant;
            bottom.detailWidthConstraint.constant = bottom.view.frame.size.width - bottom.masterWidthConstraint.constant;
            bottom.masterXOffsetConstraint.constant = 0.0;
            [bottom layoutMasterAndDetailViews];
        }];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end


@implementation UIViewController (CBISplitViewController)

- (CBISplitViewController *)cbi_splitViewController
{
    CBISplitViewController *parent = (CBISplitViewController *)self.parentViewController;
    while (parent && ![parent isKindOfClass:[CBISplitViewController class]]) {
        parent = (CBISplitViewController *)parent.parentViewController;
    }
    return parent;
}

@end