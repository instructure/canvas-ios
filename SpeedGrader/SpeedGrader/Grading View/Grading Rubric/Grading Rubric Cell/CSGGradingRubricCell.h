//
//  CSGGradingRubricCell.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CSGBadgeView.h"

@interface CSGGradingRubricCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *rubricDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *pointsBadge;
@property (nonatomic, strong) UIColor *selelectedPointsColor;

@end
