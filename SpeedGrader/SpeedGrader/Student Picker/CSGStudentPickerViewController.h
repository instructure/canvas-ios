//
//  CSGStudentPickerViewController.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGStudentPickerViewController : UIViewController

@property (nonatomic, strong) RACSignal *submissionRecordPickedSignal;

+ (instancetype)instantiateFromStoryboard;

@end
