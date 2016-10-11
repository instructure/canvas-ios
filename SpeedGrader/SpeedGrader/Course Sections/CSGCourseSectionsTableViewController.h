//
//  CSGCourseSectionsTableViewController.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGCourseSectionsTableViewController : UITableViewController

@property (nonatomic, strong) CKICourse *course;

+ (instancetype)instantiateFromStoryboard;

- (CGFloat)preferredHeight;
- (CGFloat)preferredWidth;

@end
