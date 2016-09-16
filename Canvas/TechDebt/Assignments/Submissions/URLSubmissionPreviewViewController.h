//
//  URLSubmissionPreviewViewController.h
//  iCanvas
//
//  Created by BJ Homer on 5/1/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLSubmissionPreviewViewController : UIViewController

@property (copy) void(^onSubmit)(NSURL *url);
@property BOOL shouldHideCancelButton;

+ (UIViewController *)createWithSubmissionHandler:(void(^)(NSURL *url))handler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil __attribute__((unavailable("Use -initWithSubmissionHandler")));

@end
