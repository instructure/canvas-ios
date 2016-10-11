//
//  CSGVideoSlider.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 1/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGVideoSlider : UIControl

@property (nonatomic, assign) float value; // observable
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;

@property (nonatomic, assign, getter=isContinuous) BOOL continuous; // defaults to YES

@property (nonatomic, strong) UIColor *strokeColor; // defaults to white
@property (nonatomic, strong) UIColor *fillColor; // defaults to white

@end