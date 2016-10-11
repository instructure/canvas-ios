//
//  CSGNoResultsView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGNoResultsView.h"

@implementation CSGNoResultsView

+ (instancetype)instantiateFromXib {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    CSGNoResultsView *instance = (CSGNoResultsView *)[nibViews objectAtIndex:0];
    NSAssert([instance isKindOfClass:[self class]], @"View from nib is not an instance of %@", NSStringFromClass(self));
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    
    self.commentLabel.backgroundColor = [UIColor clearColor];
    self.commentLabel.font = [UIFont systemFontOfSize:24.0f];
    self.commentLabel.textColor = self.tintColor;
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.tintColor = self.tintColor;
    
    self.tintColor = [UIColor lightGrayColor];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    self.commentLabel.textColor = self.tintColor;
    self.imageView.tintColor = self.tintColor;
}

@end
