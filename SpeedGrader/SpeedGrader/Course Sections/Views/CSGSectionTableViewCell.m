//
//  CSGSectionTableViewCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSectionTableViewCell.h"

@implementation CSGSectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.sectionNameLabel.textColor = RGB(77, 78, 80);
    self.checkmarkImageView.tintColor = RGB(77, 78, 80);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
