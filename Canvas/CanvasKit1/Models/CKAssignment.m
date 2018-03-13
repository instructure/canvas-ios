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
    
    

#import "CKAssignment.h"
#import "CKCanvasAPI.h"
#import "CKCourse.h"
#import "CKStudent.h"
#import "CKSubmission.h"
#import "CKRubric.h"
#import "CKDiscussionTopic.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "CKSubmissionType.h"
#import "NSDictionary+CKAdditions.h"
#import "NSString+CKAdditions.h"

@implementation CKAssignment

@synthesize ident, type, name, course, assignmentDescription, submissions, rubric, scoringType, pointsPossible;
@synthesize assignmentGroupId, position, discussionTopic, useRubricForGrading, submissionTypes;
@synthesize needsGradingCount, anonymousSubmissions, allowedExtensions;
@synthesize dueDate;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        submissions = [[NSMutableDictionary alloc] init];
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    info = [info safeCopy];
    
    self.ident = [info[@"id"] unsignedLongLongValue];
    
    _courseIdent = [info[@"course_id"] unsignedLongLongValue];
    
    self.name = info[@"name"];
    self.assignmentDescription = info[@"description"];
    
    id rawDateStr = info[@"due_at"];
    
    if ([rawDateStr isKindOfClass:[NSString class]]) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *date = [formatter dateFromString:rawDateStr];
        self.dueDate = date;
    }
    
    if (info[@"rubric"]) {
        self.rubric = [[CKRubric alloc] initWithInfo:info andAssignment:self];
        self.useRubricForGrading = [info[@"use_rubric_for_grading"] boolValue];
    }
    
    self.scoringType = CKAssignmentScoringTypePoints;
    NSString *scoringTypeString = info[@"grading_type"];
    if ([scoringTypeString isEqual:@"pass_fail"]) {
        self.scoringType = CKAssignmentScoringTypePassFail;
    }
    else if ([scoringTypeString isEqual:@"percent"]) {
        self.scoringType = CKAssignmentScoringTypePercentage;
    }
    else if ([scoringTypeString isEqual:@"letter_grade"]) {
        self.scoringType = CKAssignmentScoringTypeLetter;
    }
    
    self.pointsPossible = [info[@"points_possible"] doubleValue];
    
    self.assignmentGroupId = [info[@"assignment_group_id"] unsignedLongLongValue];
    NSNumber *positionNum = info[@"position"];
    if ([positionNum isKindOfClass:[NSNumber class]]) {
        self.position = [positionNum intValue];
    }
    
    CKSubmissionType typeField = 0;
    NSArray *typeStrings = info[@"submission_types"];
    for (NSString *typeString in typeStrings) {
        typeField |= submissionTypeForString(typeString);
    }
    
    NSString *urlString = info[@"url"];
    if ([urlString isKindOfClass:[NSString class]]) {
        self.url = [NSURL URLWithString:urlString];
    }
    
    self.submissionTypes = typeField;
    self.type = [CKAssignment assignmentTypeForSubmissionsTypes:typeStrings];
    
    if (info[@"discussion_topic"]) {
        self.discussionTopic = [[CKDiscussionTopic alloc] initWithInfo:info[@"discussion_topic"] andAssignment:self];
    }
    
    self.needsGradingCount = [info[@"needs_grading_count"] integerValue];
    self.anonymousSubmissions = [info[@"anonymous_submissions"] boolValue];
    
    self.allowedExtensions = info[@"allowed_extensions"];
    
    self.quizIdent = [info[@"quiz_id"] unsignedLongLongValue];
    
    _contentLock = [CKContentLock contentLockWithInfo:info];
    
    self.groupCategoryID = info[@"group_category_id"];

    NSString *externalToolTagAttributesURL = [info valueForKeyPath:@"external_tool_tag_attributes.url"];
    if ([externalToolTagAttributesURL isKindOfClass:[NSString class]]) {
        self.externalToolTagAttributesURL = [NSURL URLWithString:externalToolTagAttributesURL];
    }
}


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
    }
    return CKAssignmentTypeAssignment;
}

- (BOOL)allowsExtension:(NSString *)extension
{
    if (!self.allowedExtensions) {
        return YES;
    }
    
    extension = [extension lowercaseString];
    BOOL allowed = NO;
    for (NSString *allowedExtension in self.allowedExtensions) {
        if ([extension isEqualToString:[allowedExtension lowercaseString]]) {
            allowed = YES;
            break;
        }
    }
    return allowed;
}

- (NSString *)notAllowedAlertTitle:(NSString *)extension
{
    NSString *titleFormat = NSLocalizedString(@"File extension not allowed: %@", @"The file extension for a submission is not acceptable");
    return [NSString stringWithFormat:titleFormat, extension];
}

- (NSString *)notAllowedAlertMessage
{
    NSAssert(self.allowedExtensions.count > 0, @"All extensions are allowed since no limits given");
    
    NSString *baseString = NSLocalizedString(@"File extension(s) permitted for this assignment: ",
                                             @"Comes before a list of file extensions allowed for an assinment submission");
    NSMutableString *permittedExtensionsStr = [baseString mutableCopy];
    
    [permittedExtensionsStr appendString:(self.allowedExtensions)[0]];
    if (self.allowedExtensions.count > 1) {
        for (int i = 1; i < self.allowedExtensions.count; i++) {
            [permittedExtensionsStr appendFormat:@", %@", (self.allowedExtensions)[i]];
        }
    }
    
    return permittedExtensionsStr;
}

- (NSComparisonResult)comparePosition:(CKAssignment *)other
{
    if (self.position < other.position) {
        return NSOrderedAscending;
    }
    else if (self.position > other.position) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

-(NSUInteger)hash {
    return (NSUInteger)self.ident;
}

- (NSString *)gradeStringForSubmission:(CKSubmission *)submission usingEnteredGrade:(BOOL)useEnteredGrade
{
    NSString *submissionGrade = useEnteredGrade ? submission.enteredGrade : submission.grade ?: @"—";
    
    switch (self.scoringType) {
        case CKAssignmentScoringTypePassFail: {
            if ([submissionGrade equalIgnoringCase:@"complete"]) {
                return NSLocalizedString(@"Complete", @"Assignment grade: Complete");
            }
            else if ([submissionGrade equalIgnoringCase:@"not complete"]) {
                return NSLocalizedString(@"Not Complete", @"Pass/fail assignment is not complete");
            }
            else if ([submissionGrade equalIgnoringCase:@"incomplete"]) {
                return NSLocalizedString(@"Incomplete", @"Assignment grade: Incomplete");
            }
            
            // Previous functionality just returned the value so this is at least as good as that
            return submissionGrade;
            break;
        }
        case CKAssignmentScoringTypeLetter:
            [self setAccessibilityLabel:[NSString stringWithFormat:@"%@", submissionGrade]];
            return submissionGrade;
            break;
        case CKAssignmentScoringTypePercentage:
            [self setAccessibilityLabel:[NSString stringWithFormat:@"%@%%", submissionGrade]];
            return [NSString stringWithFormat:@"%@%%", submissionGrade];
            break;
        case CKAssignmentScoringTypePoints: {
            [self setAccessibilityLabel:[NSString stringWithFormat:@"%@ %@ %g", submissionGrade, NSLocalizedString(@"out of", @"Accessibility label for out or grading style"), self.pointsPossible]];

            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setMaximumFractionDigits:2];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            // all numbers come back from the api formated in EN so we need to parse it as
            // en and then we can format with the users locale
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
            NSNumber *gradeNumber = [formatter numberFromString:submissionGrade];
            [formatter setLocale:[NSLocale currentLocale]];

            if (gradeNumber) {
                return [NSString stringWithFormat:@"%@/%g", [formatter stringFromNumber:gradeNumber], self.pointsPossible];
            } else {
                // Grade is not a number
                // Most likely because it is a letter and we are using a GPA scale.
                return submissionGrade;
            }

            break;
        }
        default: {
            return submissionGrade;
            break;
        }
    }
}

@end



@implementation CKAssignment (SpeedGrader)

- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)aCourse {
    self = [self initWithInfo:info];
    if (self) {
        course = aCourse;
    }
    return self;
}

- (void)updateNeedsGradingCount
{
    NSLog(@"Warning: Trying to update grading count, but course is not set.");
    NSInteger count = 0;
    for (NSString *submissionKey in self.submissions) {
        CKSubmission *submission = (self.submissions)[submissionKey];
        if (submission.needsGrading) {
            count++;
        }
    }
    
    self.needsGradingCount = count;
    [self.course updateNeedsGradingCount];
}

- (CKSubmission *)submissionForStudent:(CKStudent *)student
{
    CKSubmission *submission = (self.submissions)[student.keyString];
    if (!submission) {
        submission = [[CKSubmission alloc] initPlaceholderForStudent:student andAssignment:self];
        (self.submissions)[student.keyString] = submission;
    }
    return submission;
}

@end
