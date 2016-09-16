//
//  CBISubmissionCommentCell.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit1/CKRemoteImageView.h>


@class CBISubmissionCommentViewModel;


@interface CBISubmissionCommentCell : UITableViewCell
@property (nonatomic) CBISubmissionCommentViewModel *viewModel;
- (void)updateFonts;
@property (weak, nonatomic) IBOutlet CKRemoteImageView *avatarImageView;
@end
