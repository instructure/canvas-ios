//
//  CNVTableViewCell.m
//  iCanvas
//
//  Created by Mark Suman on 10/20/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "CNVTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+TechDebt.h"

@interface CNVTableViewCell ()
- (void)setupBackground;
@end

@implementation CNVTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupBackground];
    }
    return self;
}

- (void)setupBackground {
    
    UIImage *cellBackgroundImage = [UIImage techDebtImageNamed:@"tableviewcell-background"];
    cellBackgroundImage = [cellBackgroundImage resizableImageWithCapInsets:
                           UIEdgeInsetsMake(0,
                                            0,
                                            cellBackgroundImage.size.height - 1,
                                            0)];
    UIImageView *gradientBackgroundView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
    gradientBackgroundView.contentMode = UIViewContentModeScaleToFill;
    gradientBackgroundView.frame = self.bounds;
    gradientBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView = gradientBackgroundView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupBackground];

}

@end
