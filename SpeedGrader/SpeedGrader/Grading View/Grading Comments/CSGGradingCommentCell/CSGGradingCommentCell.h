//
//  CSGGradingCommentCell.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGGradingCommentCell : UITableViewCell

@property (nonatomic, strong) CKISubmissionComment *comment;

@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *commentContainerView;
@property (nonatomic, weak) IBOutlet UIView *mediaContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *commentContainerImageView;

@end
