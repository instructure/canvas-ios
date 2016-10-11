//
//  CSGNoResultsView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGNoResultsView : UIView

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;

+ (instancetype)instantiateFromXib;

@end
