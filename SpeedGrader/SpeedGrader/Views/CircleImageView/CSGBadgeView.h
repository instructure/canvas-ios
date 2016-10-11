//
//  CSGBadgeView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/1/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGBadgeView : UIView

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *badgeLabel;

@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;

@end
