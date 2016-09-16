//
//  SubtitleAndRightDetailCell.h
//  iCanvas
//
//  Created by BJ Homer on 2/13/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubtitleAndRightDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightDetailLabel;

// Doing it this way keeps UITableViewCell from messing with the layout.

- (UILabel *)textLabel; // Alias for mainTextLabel;
- (UILabel *)detailTextLabel; // Alias for rightDetailLabel

@end
