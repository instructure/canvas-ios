//
//  CKRubricViewController.m
//  iCanvas
//
//  Created by Mark Suman on 2/17/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>
#import "RubricViewController.h"
#import <CanvasKit1/CKCanvasAPI.h>
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/CKRubricView.h>

#import "RubricViewController.h"
#import "iCanvasErrorHandler.h"
#import "CBILog.h"

@implementation RubricViewController

- (id)init
{
    return [self initWithSubmission:nil];
}

- (id)initWithSubmission:(CKSubmission *)aSubmission
{
    self = [super init];
    
    if (self) {
        self.submission = aSubmission;
    }
    
    return self;
}

- (void)loadView
{
    CKRubricView *aRubricView;
    aRubricView = (id)[[CKRubricView alloc] initWithFrame:CGRectMake(0, 0, 320, 436)];
    
    aRubricView.rubric = self.submission.assignment.rubric;
    aRubricView.assessment = self.submission.rubricAssessment;
    aRubricView.readOnly = YES;
    self.view = aRubricView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self resizeRubricPopover];
    
    // TODO: Add GAI Event
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self fetchSubmission];
}

- (void)fetchAssignment
{
    if (self.assignmentId == 0 || !self.canvasAPI || !self.contextInfo) {
        return;
    }
    
    [self.canvasAPI getAssignmentForContext:self.contextInfo assignmentIdent:self.assignmentId block:^(NSError *error, CKAssignment *assignment) {
        self.assignment = assignment;
    }];
}

- (void)fetchSubmission
{
    if (self.submission || !self.canvasAPI) {
        return;
    }
    
    if (self.assignment == nil) {
        [self fetchAssignment];
        return;
    }
    
    CKUser *user = self.canvasAPI.user;
    int64_t userId = user.ident;
    [self.canvasAPI getSubmissionForAssignment:self.assignment studentID:userId includeHistory:NO block:^(NSError *error, BOOL isFinalValue, id object) {
        if (error) {
            [[iCanvasErrorHandler sharedErrorHandler] logError:error];
        }
        self.submission = object;
    }];
}

- (void)setAssignmentId:(uint64_t)assignmentId
{
    if (_assignmentId == assignmentId) {
        return;
    }
    _assignmentId = assignmentId;
    
    // set the assignment to nil if it doesn't match
    if (assignmentId != _assignment.ident) {
        self.assignment = nil;
    }
}

- (void)setAssignment:(CKAssignment *)assignment
{
    if (_assignment == assignment)
    {
        return;
    }
    _assignment = assignment;
    self.assignmentId = _assignment.ident;
    
    if (self.submission.assignment.ident != _assignment.ident) {
        self.submission = nil;
    }
    
    [self updateRubricView];
    [self fetchSubmission];
}

- (void)updateRubricView
{
    CKRubricView *rubric = (CKRubricView *)self.view;
    rubric.rubric = self.assignment.rubric;
    rubric.assessment = self.submission.rubricAssessment;
}

- (void)setSubmission:(CKSubmission *)submission
{
    if (_submission == submission) {
        return;
    }
    _submission = submission;
    [self setAssignment:submission.assignment];
    [self updateRubricView];
}


- (void)resizeRubricPopover
{    
    CKRubricView *rubricView = (CKRubricView *)self.view;
    CGFloat newHeight = rubricView.tableView.contentSize.height;
    
    CGSize newSize = CGSizeMake(self.preferredContentSize.width, newHeight);
    [self setPreferredContentSize:newSize];
}

- (UITableView *)rubricTableView
{
    return ((CKRubricView *)self.view).tableView;
}

@end
