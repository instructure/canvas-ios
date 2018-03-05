//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
            return submissionViewModel.record.attempt > 0 ? NSLocalizedString(@"Submitted", @"Submitted grouping") : NSLocalizedString(@"No Submission", @"No Submission groupong");
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
