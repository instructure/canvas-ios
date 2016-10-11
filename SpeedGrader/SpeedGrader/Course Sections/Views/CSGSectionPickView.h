//
//  CSGSectionPickView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 10/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGSectionPickView : UIView

@property (nonatomic, weak) IBOutlet UILabel *sectionNameLabel;

+ (instancetype)instantiateFromXib;

@end
