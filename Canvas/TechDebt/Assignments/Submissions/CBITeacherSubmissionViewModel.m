//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CBITeacherSubmissionViewModel.h"
#import "CBIStudentSubmissionViewModel.h"
@import CanvasKeymaster;

@implementation CBITeacherSubmissionViewModel

@dynamic model;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(CBIStudentSubmissionViewModel *submissionViewModel) {
            return @(submissionViewModel.record.attempt > 0);
        } groupTitleBlock:^NSString *(CBIStudentSubmissionViewModel *submissionViewModel) {
            NSBundle *bundle = [NSBundle bundleForClass:self.class];
            return submissionViewModel.record.attempt > 0 ? NSLocalizedStringFromTableInBundle(@"Submitted", nil, bundle, @"Submitted grouping") : NSLocalizedStringFromTableInBundle(@"No Submission", nil, bundle, @"No Submission groupong");
        } sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"student.sortableName" ascending:YES]]];
    }
    return self;
}

- (UIViewController *)createViewController {
    MLVCTableViewController *table = [MLVCTableViewController new];
    if (@available(iOS 11.0, *)) {
        table.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    table.viewModel = self;
    return table;
}

- (RACSignal *)refreshViewModelsSignal {
    RACSignal *tint = RACObserve(self, tintColor);
    CKIAssignment *assignment = self.model;
    return [[[[TheKeymaster.currentClient fetchSubmissionRecordsForAssignment:self.model] flattenMap:^id(NSArray *records) {
        return [records.rac_sequence.signal flattenMap:^__kindof RACStream *(CKISubmissionRecord *record) {
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
