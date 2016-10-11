//
//  CSGSectionPickView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 10/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSectionPickView.h"

@implementation CSGSectionPickView

+ (instancetype)instantiateFromXib {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    CSGSectionPickView *instance = (CSGSectionPickView *)[nibViews objectAtIndex:0];
    NSAssert([instance isKindOfClass:[self class]], @"View from nib is not an instance of %@", NSStringFromClass(self));
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.sectionNameLabel.textColor = [UIColor whiteColor];
}

@end
