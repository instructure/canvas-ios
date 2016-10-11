//
//  CSGStudentPickerCell.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/6/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGStudentPickerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *checkmarkImageView;
@property (nonatomic, weak) IBOutlet UILabel *studentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *studentNameLabelWhenLate;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *lateLabel;

@end
