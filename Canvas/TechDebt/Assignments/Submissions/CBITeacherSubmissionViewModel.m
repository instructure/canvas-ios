//
//  CBITeacherSubmissionViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBITeacherSubmissionViewModel.h"
#import "CBIStudentSubmissionViewModel.h"
@import CanvasKeymaster;

@implementation CBITeacherSubmissionViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(CBIStudentSubmissionViewModel *submissionViewModel) {
            return @(submissionViewModel.record.attempt > 0);
        } groupTitleBlock:^NSString *(CBIStudentSubmissionViewModel *submissionViewModel) {
            return submissionViewModel.record.attempt > 0 ? NSLocalizedString(@"Submitted", @"Submitted grouping") : NSLocalizedString(@"No Submission", @"No Submission groupong");
        } sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"student.sortableName" ascending:YES]]];
    }
    return self;
}

- (UIViewController *)createViewController {
    MLVCTableViewController *table = [MLVCTableViewController new];
    table.viewModel = self;
    return table;
}

- (RACSignal *)refreshViewModelsSignal {
    RACSignal *tint = RACObserve(self, tintColor);
    CKIAssignment *assignment = self.model;
    return [[[[TheKeymaster.currentClient fetchSubmissionRecordsForAssignment:self.model] flattenMap:^id(NSArray *records) {
        return [records.rac_sequence.signal flattenMap:^RACStream *(CKISubmissionRecord *record) {
            CKIUser *user = [CKIUser modelWithID:record.userID context:assignment.context];
            return [[TheKeymaster.currentClient refreshModel:user parameters:@{}] map:^id(CKIUser *user) {
                CBIStudentSubmissionViewModel *studentSubmission = [CBIStudentSubmissionViewModel viewModelForModel:assignment];
                studentSubmission.record = record;
                studentSubmission.student = user;
                studentSubmission.forTeacher = YES;
                RAC(studentSubmission, tintColor) = tint;
                return @[studentSubmission];
            }];
        }];
    }] logAll] replay];
}

@end
