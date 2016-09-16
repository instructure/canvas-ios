//
//  WebBrowserViewController.h
//  iCanvas
//
//  Created by Mark Suman on 10/24/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserViewController : UIViewController

// EITHER
@property (nonatomic) NSURL *url;
// OR
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, copy) void (^browserWillDismissBlock)();

@end
