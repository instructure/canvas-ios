//
//  CSGBadgeView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/1/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGBadgeView.h"

@implementation CSGBadgeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeViews];
}

- (void)initializeViews {
    
    self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.backgroundView setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    self.backgroundView.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.badgeLabel setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundView addSubview:self.badgeLabel];
    
    // Default Badge Settings
    self.borderColor = [UIColor whiteColor];
    self.borderWidth = 3.0f;
    self.backgroundView.backgroundColor = [UIColor redColor];
    
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
 
    [self refreshDimensions];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshDimensions];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self refreshDimensions];
}

- (void)refreshDimensions {
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2.f;
    
    self.backgroundView.frame = CGRectInset(self.bounds, _borderWidth, _borderWidth);
    self.backgroundView.layer.cornerRadius = CGRectGetHeight(self.backgroundView.bounds) / 2.f;
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor == borderColor) {
        return;
    }
    
    _borderColor = borderColor;
    self.backgroundColor = borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth == borderWidth) {
        return;
    }
    
    _borderWidth = borderWidth;
}

@end
