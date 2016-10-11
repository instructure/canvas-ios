//
// CSGGradingViewController.h
// Created by Jason Larsen on 5/1/14.
//

#import <Foundation/Foundation.h>

extern NSString *const CSGGradingRemoveCommentsNotification;

@interface CSGGradingViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

+ (instancetype)instantiateFromStoryboard;
- (void)fetchDataForAssignment:(CKIAssignment *)assignment forCourse:(CKICourse *)course;

@end