//
//  NoPreviewAvailableController.m
//  iCanvas
//
//  Created by BJ Homer on 2/28/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "NoPreviewAvailableController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "Analytics.h"

@implementation NoPreviewAvailableController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){
        .size.height = 640,
        .size.width = 480
    }];
    view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
        .size.height = 60,
        .size.width = view.bounds.size.width
    }];
    
    label.center = (CGPoint) {
        .x = CGRectGetMidX(view.bounds),
        .y = CGRectGetMidY(view.bounds)
    };
    
    label.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
    
    NSString *explanation = NSLocalizedString(@"This file cannot be displayed on this device.", @"Text indicating a file cannot be previewed");
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@", self.url.lastPathComponent, explanation];
    label.text = text;
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.textColor = [UIColor colorWithWhite:0 alpha:0.9];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:label];
    
    self.view = view;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [Analytics logScreenView:kGAIScreenNoPreviewAvailable];
}

@end