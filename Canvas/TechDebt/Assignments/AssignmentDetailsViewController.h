//
//  AssignmentDetailsViewController.h
//  iCanvas
//
//  Created by derrick on 4/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKAssignment;
@interface AssignmentDetailsViewController : UIViewController
@property (nonatomic) CKAssignment *assignment;
@property (nonatomic) BOOL prependAssignmentInfoToContent;
@property (nonatomic) CGFloat topContentInset;
@property (nonatomic) CGFloat bottomContentInset;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (UIScrollView *)scrollView;

@end
