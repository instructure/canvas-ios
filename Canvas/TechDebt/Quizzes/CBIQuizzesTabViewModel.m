//
//  CBIQuizzesTabViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 3/19/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
