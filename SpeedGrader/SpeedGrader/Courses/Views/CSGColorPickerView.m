//
//  CSGColorPickerView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGColorPickerView.h"

@interface CSGColorPickerView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) NSArray *buttonColors;
@property (strong, nonatomic) NSArray *buttonColorNames;
@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation CSGColorPickerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.buttonColors = [UIColor csg_courseColors];
    self.buttonColorNames = [UIColor csg_courseColorNames];
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.tag = idx;
        [button setBackgroundColor:self.buttonColors[idx]];
        
        [button.layer setCornerRadius:3.0f];
        [button setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"%@", @"Accessibility label for button to select %@ as the color for the course"), [self colorNameForButtonColor:button.tag], [self colorNameForButtonColor:button.tag]]];
        [button setAccessibilityHint:[NSString stringWithFormat:NSLocalizedString(@"Sets the course color to %@", @"Accessibility hint for a course color button"),[self colorNameForButtonColor:button.tag], [self colorNameForButtonColor:button.tag]]];
        
    }];
}

- (IBAction)colorButtonTouched:(UIButton *)button
{
    [self deselectButton:self.selectedButton];
    [self selectButton:button];
    [self.delegate didPickColor:self.buttonColors[button.tag]];
    
}

- (NSString *)colorNameForButtonColor:(NSInteger )colorIndex
{
    return self.buttonColorNames[colorIndex];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if (_selectedColor == selectedColor) {
        return;
    }
    
    _selectedColor = selectedColor;
    [self reloadButtons];
}

- (void)reloadButtons {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if ([button.backgroundColor.description isEqualToString:self.selectedColor.description]) {
            [self selectButton:button];
        } else {
            [self deselectButton:button];
        }
    }];
}

- (void)selectButton:(UIButton *)button
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:3.0f];
    animation.toValue = [NSNumber numberWithFloat:16.0f];
    animation.duration = 0.1;
    
    [button.layer addAnimation:animation forKey:@"cornerRadius"];
    [button.layer setCornerRadius:14.0f];
    [button setImage:[UIImage imageNamed:@"icon_checkmark_white"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    
    [self setSelectedButton:button];
}

- (void)deselectButton:(UIButton *)button
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:16.0f];
    animation.toValue = [NSNumber numberWithFloat:3.0f];
    animation.duration = 0.1;
    
    [button.layer addAnimation:animation forKey:@"cornerRadius"];
    [button.layer setCornerRadius:2.0f];
    [button setImage:nil forState:UIControlStateNormal];
}

- (void)setButtonsAccessible:(BOOL)isAccessible
{
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button setAccessibilityElementsHidden:!isAccessible];
    }];
}

@end
