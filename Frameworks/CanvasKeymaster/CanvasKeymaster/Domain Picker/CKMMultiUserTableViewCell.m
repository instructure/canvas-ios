//
//  CBIMultiUserTableViewCell.m
//  iCanvas
//
//  Created by Brandon Pluim on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMMultiUserTableViewCell.h"

@implementation CKMMultiUserTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.backgroundColor =  [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.8f];
    self.selectedBackgroundView = selectedBackgroundView;

    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.deleteButton setImage:[[UIImage imageNamed:@"icon_x_delete" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self.deleteButton setAccessibilityLabel:NSLocalizedString(@"remove user", @"Placeholder for delete icon in Multi User Table View Cell")];
    
    [self.deleteButton setTintColor:[UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1.f]];
}

@end
