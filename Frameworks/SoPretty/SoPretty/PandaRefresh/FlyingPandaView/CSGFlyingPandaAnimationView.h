//
//  CSGFlyingPandaAnimationView.h
//  SpeedGrader
//
//  Created by Ben Kraus on 12/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

// MEANT TO BE ABSTRACT! SUBCLASS!

static NSInteger const kFlyingPandaAnimationImageCount = 5;
static NSInteger const kCloudAnimationImageCount = 5;
UIImage *imageNamed(NSString *name);

@interface CSGFlyingPandaAnimationView : UIView

@property (nonatomic, strong) UIImageView *flyingPandaImageView;
@property (nonatomic, strong) NSMutableArray *onscreenClouds;

- (void)startAnimating;
- (void)stopAnimating;

@end
