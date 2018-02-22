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
    
    

#import "CKSubmission.h"
#import "CKCanvasAPI.h"
#import "CKSubmissionAttempt.h"
#import "CKAssignment.h"
#import "CKCourse.h"
#import "CKStudent.h"
#import "CKSubmissionComment.h"
#import "CKRubricAssessment.h"
#import "NSDictionary+CKAdditions.h"

@interface CKSubmission () {
    NSDictionary *_raw;
}

- (void)updateOrCreateNewAttemptWithInfo:(NSDictionary *)attemptInfo;
@end

@implementation CKSubmission

- (id)initPlaceholderForStudent:(CKStudent *)aStudent andAssignment:(CKAssignment *)anAssignment
{
    self = [super init];
    if (self) {
        _ident = aStudent.ident;
        _assignment = anAssignment;
        _student = aStudent;
        _internalIdent = [NSString stringWithFormat:@"%qu-%qu-%qu", self.ident, self.assignment.ident, self.student.ident];
        _attempts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment
{
    self = [super init];
    if (self) {
        _raw = info;
        _attempts = [[NSMutableArray alloc] init];
        _assignment = anAssignment;

        [self updateWithInfo:info];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CKSubmission (%@ - %@)>", self.assignment.name, self.student.name];
}

- (uint64_t)studentIdent {
    // The API uses the student ID as the submission ID, which is unique within the submissions on a particular assignment.
    return self.ident;
}

+ (NSString *)internalIdentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)assignment
{
    // NOTE: the rest api uses user_id when getting submissions, so that's what we use here as well
    return [NSString stringWithFormat:@"%qu", [info[@"user_id"] unsignedLongLongValue]];
}

+ (CKStudent *)studentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)assignment
{
    uint64_t studentId = [info[@"user_id"] unsignedLongLongValue];
    for (CKStudent *aStudent in assignment.course.students) {
        if (aStudent.ident == studentId) {
            return aStudent;
        }
    }
    return nil;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.freshnessDate = [NSDate date];
    
    // NOTE: the rest api uses user_id when getting submissions, so that's what we use here as well
    self.ident = [info[@"user_id"] unsignedLongLongValue];
    self.internalIdent = [CKSubmission internalIdentForInfo:info andAssignment:self.assignment];
    
    // find student
    self.student = [CKSubmission studentForInfo:info andAssignment:self.assignment];
    if (self.student == nil) {
        NSLog(@"Could not find student - not loaded yet?");
    }
    
    for (NSDictionary *attemptInfo in info[@"submission_history"]) {
        [self updateOrCreateNewAttemptWithInfo:attemptInfo];
    }
    [self.attempts sortUsingSelector:@selector(compare:)];
    
    // the attempt in submission_history that matches the current attempt won't necessarily have everything.
    [self updateOrCreateNewAttemptWithInfo:info];
    
    [self updateCommentsWithInfo:info];
    [self updateGradeWithInfo:info];
    
    NSDictionary *assessmentInfo = info[@"rubric_assessment"];
    if (assessmentInfo && (id)assessmentInfo != [NSNull null]) {
        self.rubricAssessment = [[CKRubricAssessment alloc] initWithInfo:assessmentInfo];
    }
    
    NSDictionary *turnitinData = [info objectForKeyCheckingNull:@"turnitin_data"];
    for (NSString *key in turnitinData) {
        
        
        NSDictionary *data = turnitinData[key];
        if ([data isKindOfClass:[NSDictionary class]] && data[@"similarity_score"]) {
            self.turnitinScore = @([data[@"similarity_score"] floatValue]);
        }
    }
}

- (void)updateCommentsWithInfo:(NSDictionary *)info
{
    NSMutableArray *tempComments = [NSMutableArray array];
    for (NSDictionary *commentInfo in info[@"submission_comments"]) {
        CKSubmissionComment *newComment = [[CKSubmissionComment alloc] initWithInfo:commentInfo andSubmission:self];
        [tempComments addObject:newComment];
    }
    
    // This method gets called from updateWithInfo and from SGCanvasAPI. If the submission is being updated without having the commentInfo,
    // we don't want it to clear out the comments.
    if ([tempComments count] > 0) {
        self.comments = tempComments;
    }
}

- (void)updateCommentsWithSubmission:(CKSubmission *)otherSubmission {
    NSArray *comments = otherSubmission.comments;
    if (comments.count > 0) {
        self.comments = comments;
    }
}

- (void)updateGradeWithInfo:(NSDictionary *)info
{
    NSNumber *scoreNum = info[@"score"];
    if (scoreNum && (id)scoreNum != [NSNull null]) {
        self.score = [scoreNum floatValue];
    }
    
    self.grade = [self extractGradeStringFromObject:info forKey:@"grade"];
    self.enteredGrade = [self extractGradeStringFromObject:info forKey:@"entered_grade"];

    NSNumber *enteredScore = info[@"entered_score"];
    if (enteredScore && (id)enteredScore != [NSNull null]) {
        self.enteredScore = [enteredScore floatValue];
    }
    NSNumber *pointsDeducted = info[@"points_deducted"];
    if (pointsDeducted && (id)pointsDeducted != [NSNull null]) {
        self.pointsDeducted = @([pointsDeducted floatValue]);
    }
}

- (NSString *)extractGradeStringFromObject:(NSDictionary *)object forKey:(NSString *)key
{
    NSString *grade = [object objectForKeyCheckingNull:key];

    // Make sure grade is a string
    if (grade && ![grade isKindOfClass:[NSString class]]) {
        grade = [NSString stringWithFormat:@"%@", grade];
    }
    if ([grade hasSuffix:@"%"]) {
        grade = [grade stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"%"]];
    }

    return grade;
}


- (void)updateOrCreateNewAttemptWithInfo:(NSDictionary *)attemptInfo
{
    if (![attemptInfo isKindOfClass:[NSDictionary class]]) return;
    // attempts with attempt = null are just placeholders for submissions that have comments before anything is submitted.
    if (attemptInfo[@"attempt"] != [NSNull null]) {
        NSString *newAttemptIdent = [CKSubmissionAttempt internalIdentForInfo:attemptInfo andSubmission:self];
        
        for (CKSubmissionAttempt *oldAttempt in self.attempts) {
            if ([oldAttempt.internalIdent isEqual:newAttemptIdent]) {
                [oldAttempt updateWithInfo:attemptInfo];
                return;
            }
        }
        
        CKSubmissionAttempt *attempt = [[CKSubmissionAttempt alloc] initWithInfo:attemptInfo andSubmission:self];
        [self.attempts addObject:attempt];
    }
}

- (CKSubmissionAttempt *)lastAttempt
{
    return [self.attempts lastObject];
}

- (BOOL)isPlaceholder
{
    return self.ident == 0;
}

- (BOOL)isGraded
{
    return self.grade ? YES : NO;
}

- (BOOL)needsGrading
{
    return ([self.attempts count] > 0 && (!self.lastAttempt.gradeMatchesCurrentSubmission || !self.grade));
}

- (NSString *)displayGrade
{
    NSString *displayGrade = [self.grade capitalizedString];
    if (self.assignment.scoringType == CKAssignmentScoringTypePercentage) {
        displayGrade = [displayGrade stringByAppendingString:@"%"];
    }
    else if (self.assignment.scoringType == CKAssignmentScoringTypePoints) {
        displayGrade = [displayGrade stringByAppendingFormat:@"/%g", self.assignment.pointsPossible];
    }
    return displayGrade;
}

- (NSComparisonResult)compareGrade:(CKSubmission *)other
{
    NSString *selfGrade = self.grade == nil ? @"" : self.grade;
    NSString *otherGrade = other.grade == nil ? @"" : other.grade;
    
    // First check if it needs to be graded. If so, it should be first in the list.
    // If it has no grade and no submission, it should be last in the list
    
    // order ascending:
    //   self: there is no grade but there are submisison attempts AND other has a grade
    //   self: there is a grade AND other has no grade while having no attempts  (no grade and no submission attempts should be at the end of the list)
    //   self: grade is lower than other grade
    //
    // order descending:
    //   other: there is no grade but there are submission attempts AND self has a grade
    //   other: has a grade AND self has no grade while having no attempts (no grade and no submission attempts should be at the end of the list)
    //   self: grade is higher than other grade
    //
    // order same:
    //   self & other: there is no grade but there are submission attempts
    //   self & other: there is no grade
    //   self & other: grades are equal
    
    if ([self needsGrading] || (self.grade && (!other.grade && [other.attempts count] == 0))) {
        return NSOrderedAscending;
    }
    else if ([other needsGrading] || (other.grade && (!self.grade && [self.attempts count] == 0))) {
        return NSOrderedDescending;
    }
    
    // If the grade is a number, compare it with math logic
    // Comparing numbers as strings causes numbers to be sorted incorrectly.
    if (self.assignment.scoringType == CKAssignmentScoringTypePoints || self.assignment.scoringType == CKAssignmentScoringTypePercentage) {
        if ([selfGrade floatValue] < [otherGrade floatValue]) {
            return NSOrderedAscending;
        }
        else if ([selfGrade floatValue] > [otherGrade floatValue]) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }
    
    return [selfGrade compare:otherGrade];
}

// We pass in both the submission and assignment because the submission could be nil,
// which would mean that we couldn't pull the assignment out of it
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission {
    return [self gradeStringForAssignment:assignment grade:submission.grade points:submission.score hasSubmission:submission != nil isGraded:submission.isGraded];
}


+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment grade:(NSString *)grade points:(float)score hasSubmission:(BOOL)hasSubmission isGraded:(BOOL)graded
{
    NSString *gradeString = @"";
    NSString *pointsPossible = [NSString stringWithFormat:@"%g", assignment.pointsPossible];
    
    // If we have pointsPossible, add that
    if (pointsPossible.length > 0) {
        gradeString = [NSString stringWithFormat:NSLocalizedString(@"out of %@", @"The assignment is out of 100 points"),pointsPossible];
    }
    
    // If we have a submission, we might add more to the string
    if (hasSubmission) {
        NSString *passFailString = @"";

        if (grade.length > 0) {
            switch (assignment.scoringType) {
                case CKAssignmentScoringTypePoints:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@ out of %@", @"88 out of 100 points"),grade,pointsPossible];
                    break;
                case CKAssignmentScoringTypePercentage:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@%% (%g out of %@)", @"83% (83 out of 100 points"),grade,score,pointsPossible];
                    break;
                    
                case CKAssignmentScoringTypePassFail:
                    if ([grade isEqualToString:@"complete"]) {
                        passFailString = NSLocalizedString(@"Complete", @"Assignment grade: Complete");
                    }
                    else if ([grade isEqualToString:@"incomplete"]) {
                        passFailString = NSLocalizedString(@"Incomplete", @"Assignment grade: Incomplete");
                    }
                    else {
                        passFailString = grade;
                    }
                    
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@ (%g out of %@)", @"B- (83 out of 100 points"),passFailString,score,pointsPossible];
                    break;
                case CKAssignmentScoringTypeLetter:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@ (%g out of %@)", @"B- (83 out of 100 points"),grade,score,pointsPossible];
                    break;
                default:
                    
                    break;
            }
        } else if (!graded) {
            if (pointsPossible) {
                gradeString = [NSString stringWithFormat:NSLocalizedString(@"Not graded (0 out of %@)", @"not graded with points possible"), pointsPossible];
            } else {
                gradeString = NSLocalizedString(@"Not graded", @"not graded string.");
            }
        } else if (score) {
            gradeString = [NSString stringWithFormat:NSLocalizedString(@"%g out of %@", @"88 out of 100 points"), score, pointsPossible];
        }
    }
    
    return gradeString;
}

+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andAttempt:(CKSubmissionAttempt *)attempt
{
    return [self gradeStringForAssignment:assignment grade:attempt.grade points:attempt.score hasSubmission:attempt != nil isGraded:attempt && attempt.score != -1];
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[ @"attempts", @"lastAttempt", @"comments" ];
}

- (NSUInteger)hash {
    return (NSUInteger)self.ident;
}

- (BOOL)hasLatePolicyApplied {
    return self.pointsDeducted != nil;
}

@end



