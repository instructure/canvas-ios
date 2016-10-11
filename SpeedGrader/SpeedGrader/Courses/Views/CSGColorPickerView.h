//
//  CSGColorPickerView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSGColorPickerViewDelegate;

@interface CSGColorPickerView : UIView

@property (nonatomic, weak) id <CSGColorPickerViewDelegate> delegate;
@property (nonatomic, strong) UIColor *selectedColor;

- (void)setButtonsAccessible:(BOOL)isAccessible;

@end

@protocol CSGColorPickerViewDelegate <NSObject>

- (void)didPickColor:(UIColor *)color;

@end
