//
//  MLVCViewController.m
//  MyLittleViewController
//
//  Created by derrick on 11/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "MLVCViewController.h"

@implementation MLVCViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [self.viewModel viewControllerViewDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillAppear:)]) {
        [self.viewModel viewController:self viewWillAppear:animated];
    }
    
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        [self.viewModel refreshViewModelSignalForced:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillDisappear:)]) {
        [self.viewModel viewController:self viewWillDisappear:animated];
    }
}

- (void)setViewModel:(id<MLVCViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;

    if (self.isViewLoaded && [_viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [_viewModel viewControllerViewDidLoad:self];
    }
}

@end
