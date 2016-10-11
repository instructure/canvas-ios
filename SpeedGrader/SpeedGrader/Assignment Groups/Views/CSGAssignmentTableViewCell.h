//
//  CSGAssignmentTableViewCell.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 10/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSGBadgeView;

@interface CSGAssignmentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet CSGBadgeView *needsGradingBadgeView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nameLabelCenterConstraint;

@property (nonatomic, strong) CKIAssignment *assignment;

- (void)setNeedsGradingCountForSection:(NSString *)sectionId;

@end
