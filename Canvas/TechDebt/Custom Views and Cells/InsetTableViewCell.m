//
//  InsetTableViewCell.m
//  iCanvas
//
//  Created by rroberts on 9/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "InsetTableViewCell.h"

@implementation InsetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectInset(frame, 9, 0)];
}

@end
