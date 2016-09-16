//
//  CBIAssignmentSubmissionsViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIStudentSubmissionViewModel.h"
#import "CBISubmissionCommentViewModel.h"
#import "CBISubmissionViewModel.h"
#import "CBIStudentSubmissionViewController.h"
#import "CBIAddSubmissionCommentViewModel.h"

#import "CBIColorfulViewModel+CellViewModel.h"
#import "UIViewController+Transitions.h"
#import "EXTScope.h"

@import CanvasKeymaster;

@implementation CBIStudentSubmissionViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(id object) {
            if ([object isKindOfClass:[CBIAddSubmissionCommentViewModel class]]) {
                return @(0);
            } else {
                return @(1);
            }
        } groupTitleBlock:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        RAC(self, name) = RACObserve(self, student.name);
        RAC(self, viewControllerTitle) = RACObserve(self, student.name);
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController {
    [CBISubmissionCommentViewModel registerCellsForTableView:tableViewController.tableView];
    [CBISubmissionViewModel registerCellsForTableView:tableViewController.tableView];
    [super tableViewControllerViewDidLoad:tableViewController];
}

- (RACSignal *)refreshViewModelsSignal {
    
    RACSignal *tintColor = RACObserve(self, tintColor);
    
    RACSignal *nonNilStudentID = [[RACObserve(self, student.id) filter:^BOOL(id value) {
        return value != nil;
    }] take:1];
    
    RACSignal *submissionRecords = [nonNilStudentID flattenMap:^RACStream *(NSString *studentID) {
        return [[[CKIClient currentClient] fetchSubmissionRecordForAssignment:self.model forStudentWithID:studentID] logError];
    }];
    
    @weakify(self)
    return [submissionRecords map:^id(CKISubmissionRecord *record) {
        @strongify(self)
        self.record = record;
        RACSequence *submissions = [[[record.submissionHistory.rac_sequence filter:^BOOL(CKISubmission *submission) {
            return submission.attempt != 0;
        }] map:[CBISubmissionViewModel modelMappingBlockObservingTintColor:tintColor]] map:^id(CBISubmissionViewModel *viewModel) {
            // attach the assignment... we'll need it later
            viewModel.assignment = record.context;
            return viewModel;
        }];
        RACSequence *comments = [record.comments.rac_sequence map:[CBISubmissionCommentViewModel modelMappingBlockObservingTintColor:tintColor]];
        return [submissions concat:comments].array;
    }];
}


- (UIViewController *)createViewController {
    CBIStudentSubmissionViewController *vc = [CBIStudentSubmissionViewController new];
    vc.viewModel = self;
    return vc;
}


- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [controller cbi_transitionToViewController:[self createViewController] animated:YES];
}

@end
