//
//  CBIGradeDetailView.h
//  iCanvas
//
//  Created by nlambson on 1/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKAssignment;
@class CKSubmission;

@interface CBIGradeDetailView : UIView
@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UIView *letterView;

- (id)initWithAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission;
@end
