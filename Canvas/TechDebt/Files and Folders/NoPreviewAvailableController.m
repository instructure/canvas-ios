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