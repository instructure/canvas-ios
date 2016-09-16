//
//  CBIAddSubmissionCommentCell.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBIAddSubmissionCommentViewModel, CBIResizableTextView;
@interface CBIAddSubmissionCommentCell : UITableViewCell
@property (nonatomic) CGFloat height;
@property (nonatomic, weak) CBIAddSubmissionCommentViewModel *viewModel;

@property (strong, nonatomic) IBOutlet CBIResizableTextView *resizeableTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attachButton;
@end
