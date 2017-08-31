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
    
    

#import "CBIQuizzesTabViewModel.h"
#import "CBIQuizViewModel.h"
@import CanvasKeymaster;

@implementation CBIQuizzesTabViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewControllerTitle = NSLocalizedString(@"Quizzes", @"The title for the list of quizzes for a course");
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:nil groupTitleBlock:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dueAt" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"model.title" ascending:YES]]];
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulSubtitleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
}


#pragma mark - syncing

- (RACSignal *)refreshViewModelsSignal
{
    BOOL isStudent = NO;
    if ([self.model.context isKindOfClass:[CKICourse class]]) {
        CKICourse *course = (CKICourse *)self.model.context;
        for (CKIEnrollment *e in course.enrollments) {
            if ((isStudent = (isStudent || e.isStudent))) break;
        }
    }
    return [[[CKIClient currentClient] fetchQuizzesForCourse:(CKICourse *)self.model.context] map:^id(NSArray *quizzes) {
        return [[[quizzes rac_sequence] filter:^BOOL(CKIQuiz *quiz) {
            return !isStudent || quiz.published;
        }] map:^id(CKIQuiz *quiz) {
            CBIQuizViewModel *quizViewModel = [CBIQuizViewModel new];
            quizViewModel.model = quiz;
            RAC(quizViewModel, tintColor) = RACObserve(self, tintColor);
            return quizViewModel;
        }].array;
    }];
}

@end
