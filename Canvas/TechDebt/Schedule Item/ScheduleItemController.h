//
//  ScheduleItemController.h
//  iCanvas
//
//  Created by derrick on 2/6/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScheduleItem, CKCourse, CKCanvasAPI, CKAssignment, CKSubmission;
@interface ScheduleItemController : UIViewController

@property (strong, nonatomic) CKCourse *course;
@property (strong, nonatomic) CKCanvasAPI *canvasAPI;

- (void)loadDetailsForScheduleItem:(ScheduleItem *)item;
- (void)loadDetailsForSyllabus:(NSString *)syllabusBody;

+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission;

@end