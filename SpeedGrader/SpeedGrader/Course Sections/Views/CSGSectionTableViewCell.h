//
//  CSGSectionTableViewCell.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGSectionTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *checkmarkImageView;
@property (nonatomic, weak) IBOutlet UILabel *sectionNameLabel;

@end
