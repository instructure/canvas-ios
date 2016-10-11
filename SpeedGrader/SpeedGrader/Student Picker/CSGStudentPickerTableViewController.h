//
//  CSGStudentPickerTableViewController.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/23/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSGStudentPickerViewController;

@interface CSGStudentPickerTableViewController : UITableViewController

@property (nonatomic, strong) CSGStudentPickerViewController *studentPickerViewController;
@property (nonatomic, strong) RACSubject *submissionRecordPickedSignal;

+ (instancetype)instantiateFromStoryboard;

@end
