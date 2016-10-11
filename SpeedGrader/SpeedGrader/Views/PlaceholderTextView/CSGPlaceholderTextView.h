//
//  CSGPlaceholderTextView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGPlaceholderTextView : UITextView

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholderText;

@end
