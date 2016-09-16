//
//  CBILTIViewController.m
//  iCanvas
//
//  Created by Derrick Hathaway on 3/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILTIViewController.h"
#import "CBIExternalToolViewModel.h"
#import <CanvasKit1/CanvasKit1.h>


@implementation CBILTIViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, externalTool) = RACObserve(self, viewModel.model);
    }
    return self;
}

- (void)awakeFromNib
{
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat bottomInset = self.tabBarController.tabBar.bounds.size.height;
    self.toolbarBottomInsetConstraint.constant = -bottomInset;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}

@end
