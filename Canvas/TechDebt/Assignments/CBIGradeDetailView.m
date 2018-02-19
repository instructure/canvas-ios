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
    
    

#import "CBIGradeDetailView.h"
#import <CanvasKit/CanvasKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import <QuartzCore/QuartzCore.h>
#import "CKIClient+CBIClient.h"
@import CanvasKeymaster;
@import CanvasCore;

@interface CBIGradeDetailView ()
@property (weak, nonatomic) IBOutlet UILabel *pointsGrade;
@property (weak, nonatomic) IBOutlet UILabel *letterGrade;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsDeductedLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalScoreLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *latePolicyConstraint;
@end

@implementation CBIGradeDetailView

- (id)initWithAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission
{
    self = [[[UINib nibWithNibName:@"CBIGradeDetailView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:nil options:nil] firstObject];
    
    if (self) {
        if (@(assignment.courseIdent) != nil) {
            self.pointsGrade.textColor = [TheKeymaster.currentClient.authSession colorForCourse:@(assignment.courseIdent).description];
            self.letterGrade.textColor = [TheKeymaster.currentClient.authSession colorForCourse:@(assignment.courseIdent).description];
            self.finalScoreLabel.textColor = [TheKeymaster.currentClient.authSession colorForCourse:@(assignment.courseIdent).description];
        } else {
            self.pointsGrade.textColor = [UIColor contextRed];
            self.letterGrade.textColor = [UIColor contextRed];
            self.finalScoreLabel.textColor = [UIColor contextRed];
        }

        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        BOOL latePolicy = [submission hasLatePolicyApplied] && assignment.scoringType != CKAssignmentScoringTypePassFail;
        if (!latePolicy) {
            [self.latePolicyConstraint setActive:NO];
            self.pointsDeductedLabel.hidden = YES;
            self.finalScoreLabel.hidden = YES;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 70);
        } else {
            if (assignment && submission) {
                self.pointsDeductedLabel.text = [NSString stringWithFormat:@"%@ (-%@)", NSLocalizedStringFromTableInBundle(@"Late Penalty", nil, bundle, nil), [submission.pointsDeducted stringValue]];
                self.finalScoreLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTableInBundle(@"Final Grade", nil, bundle, nil), [assignment gradeStringForSubmission:submission usingEnteredGrade:NO]];
            }
        }

        if (assignment.pointsPossible){
            if (submission.score != submission.score) {
                // Rare case where score is null
                self.pointsGrade.text = [NSString stringWithFormat:@"—/%g", assignment.pointsPossible];
                [self.pointsGrade setAccessibilityLabel:[NSString stringWithFormat:@"%@ %g", NSLocalizedStringFromTableInBundle(@"out of", nil, bundle, nil), assignment.pointsPossible]];
            } else {
                float score = latePolicy ? submission.enteredScore : submission.score;
                self.pointsGrade.text = [NSString stringWithFormat:@"%g/%g", score, assignment.pointsPossible];
                [self.pointsGrade setAccessibilityLabel:[NSString stringWithFormat:@"%g %@ %g", score, NSLocalizedStringFromTableInBundle(@"out of", nil, bundle, nil), assignment.pointsPossible]];
            }
        } else{
            self.pointsGrade.text = @"—/—";
            [self.pointsGrade setAccessibilityLabel:NSLocalizedStringFromTableInBundle(@"Not available", nil, bundle, nil)];
        }
        
        self.letterGrade.text = (assignment && submission) ? [assignment gradeStringForSubmission:submission usingEnteredGrade:latePolicy] : @"—";
        
        self.pointsView.layer.cornerRadius = 10;
        self.pointsView.layer.masksToBounds = YES;
        self.pointsView.layer.borderWidth = 1.0f;
        self.pointsView.layer.borderColor = [[UIColor prettyGray] CGColor];
        
        self.letterView.layer.cornerRadius = 10;
        self.letterView.layer.masksToBounds = YES;
        self.letterView.layer.borderWidth = 1.0f;
        self.letterView.layer.borderColor = [[UIColor prettyGray] CGColor];
        
        [self.pointsLabel setIsAccessibilityElement:NO];
        [self.gradeLabel setIsAccessibilityElement:NO];
        
        [self.pointsGrade setIsAccessibilityElement:NO];
        [self.letterGrade setIsAccessibilityElement:NO];
        
        [self.pointsView setIsAccessibilityElement:YES];
        [self.letterView setIsAccessibilityElement:YES];
        
        [self.pointsView setAccessibilityLabel:[NSString stringWithFormat:@"%@, %@", [self.pointsLabel accessibilityLabel], self.pointsGrade.accessibilityLabel]];
        [self.letterView setAccessibilityLabel:[NSString stringWithFormat:@"%@, %@", [self.gradeLabel accessibilityLabel], assignment.accessibilityLabel]];
    }
    return self;
}

@end
