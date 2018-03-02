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



#import "CBIAssignmentViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import "EXTScope.h"
#import "CBIStudentSubmissionViewModel.h"
#import "CBITeacherSubmissionViewModel.h"
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"

@implementation CBIAssignmentViewModel
@dynamic model;

+ (CKAssignmentType)assignmentTypeForSubmissionsTypes:(NSArray *)submissionTypeStrings
{
    // The declared types are all mutually exclusive. You will never have "discussion_topic" and "online_quiz" on the same assignment.
    // Behavior of such a scenario is undefined.
    if ([submissionTypeStrings containsObject:@"discussion_topic"]) {
        return CKAssignmentTypeDiscussion;
    }
    else if ([submissionTypeStrings containsObject:@"online_quiz"]) {
        return CKAssignmentTypeQuiz;
    }
    else if ([submissionTypeStrings containsObject:@"attendance"]) {
        return CKAssignmentTypeAttendance;
    }
    else if ([submissionTypeStrings containsObject:@"not_graded"]) {
        return CKAssignmentTypeNotGraded;
    } else if ([submissionTypeStrings containsObject:@"external_tool"]) {
        return CKAssignmentTypeExternalTool;
    }
    return CKAssignmentTypeAssignment;
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableViewController:controller cellForRowAtIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0, 64.f, 0, 0);
    return cell;
}

- (NSString *)specificImageNameForSubmissionTypes:(NSArray *)submissionTypes
{
    NSString *filename;
    switch ([CBIAssignmentViewModel assignmentTypeForSubmissionsTypes:submissionTypes]) {
        case CKAssignmentTypeQuiz:
            filename = @"quizzes";
            break;
        case CKAssignmentTypeDiscussion:
            filename = @"discussions";
            break;
        case CKAssignmentTypeExternalTool:
            filename = @"tools";
            break;
        default:
            filename = @"assignments";
            break;
    }
    return filename;
}

- (id)init
{
    self = [super init];
    if (self) {
        @weakify(self)
        RAC(self, name) = RACObserve(self, model.name);
        RAC(self, lockedItemName) = RACObserve(self, model.name);
        RAC(self, viewControllerTitle) = RACObserve(self, model.name);
        RAC(self, dueAt) = RACObserve(self, model.dueAt);
        RAC(self, syllabusDate) = RACObserve(self, model.dueAt);
        RAC(self, unlockedIcon) = [RACObserve(self, model.submissionTypes) map:^id(NSArray *submissionTypes) {
            @strongify(self)
            NSString *imageName = [NSString stringWithFormat:@"icon_%@", [self specificImageNameForSubmissionTypes:submissionTypes]];
            return [[UIImage techDebtImageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }];

        RAC(self, subtitle) = [RACObserve(self, model.dueAt) map:^id(NSDate *unformattedDueDate) {
            if (!unformattedDueDate) {
                return NSLocalizedString(@"No due date", @"String for when assignment has no due date");
            }
            static NSDateFormatter *formatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterShortStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
            });
            return [formatter stringFromDate:unformattedDueDate];
        }];
    }

    return self;
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (RACSignal *)fetchSubmissionsViewModel {
    RACSignal *isStudentSignal;
    CKICourse *courseContext = (CKICourse *)self.model.context;
    if (courseContext == nil || [courseContext isKindOfClass:[CKICourse class]]) {

        // this will be true if context is nil as well
        if (courseContext.enrollments.count == 0) {
            CKIAssignment *theAssignment = self.model;
            isStudentSignal = [[TheKeymaster.currentClient fetchCourseWithCourseID:theAssignment.courseID ?: courseContext.id] map:^id(CKICourse *course) {
                theAssignment.context = course;
                return @(course.currentUserEnrolledAsStudentOrObserver);
            }];
        } else {
            isStudentSignal = [RACSignal return:@(courseContext.currentUserEnrolledAsStudentOrObserver)];
        }

    } else {
        // as of this coding, it's not possible to add teachers to course groups, and afaik
        // assignments live in a course so having one outside a course is infeasible
        isStudentSignal = [RACSignal return:@(YES)];
    }

    CKIAssignment *assignment = self.model;
    CKIUser *currentUser = TheKeymaster.currentClient.currentUser;
    RACSignal *myTintColor = RACObserve(self, tintColor);
    return [isStudentSignal map:^id(NSNumber *isStudent) {
        if ([isStudent boolValue]) {
            CBIStudentSubmissionViewModel *studentViewModel = [CBIStudentSubmissionViewModel viewModelForModel:assignment];
            RAC(studentViewModel, tintColor) = myTintColor;
            studentViewModel.student = currentUser;
            return studentViewModel;
        } else {
            CBITeacherSubmissionViewModel *teacherViewModel = [CBITeacherSubmissionViewModel viewModelForModel:assignment];
            RAC(teacherViewModel, tintColor) = myTintColor;
            return teacherViewModel;
        }
    }];
}

@end

