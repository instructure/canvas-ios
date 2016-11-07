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

@import EnrollmentKit;
@import TooLegit;
@import CanvasKeymaster;
@import SoPretty;

@interface CBIGradeDetailView ()
@property (weak, nonatomic) IBOutlet UILabel *pointsGrade;
@property (weak, nonatomic) IBOutlet UILabel *letterGrade;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@end

@implementation CBIGradeDetailView

- (id)initWithAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission
{
    self = [[[UINib nibWithNibName:@"CBIGradeDetailView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:nil options:nil] firstObject];
    
    if (self) {
        if (@(assignment.courseIdent) != nil) {
            self.pointsGrade.textColor = [TheKeymaster.currentClient.authSession colorForCourse:@(assignment.courseIdent).description];
            self.letterGrade.textColor = [TheKeymaster.currentClient.authSession colorForCourse:@(assignment.courseIdent).description];
        } else {
            self.pointsGrade.textColor = [UIColor contextRed];
            self.letterGrade.textColor = [UIColor contextRed];
        }
        if (assignment.pointsPossible){
            self.pointsGrade.text = (submission.score) ? [NSString stringWithFormat:@"%g/%g", submission.score, assignment.pointsPossible] : [NSString stringWithFormat:@"—/%g", assignment.pointsPossible];
            [self.pointsGrade setAccessibilityLabel:[NSString stringWithFormat:@"%g %@ %g", submission.score, NSLocalizedString(@"out of", @"Accessibility label modifier for point out of point possible"), assignment.pointsPossible]];
        }else{
            self.pointsGrade.text = @"—/—";
            [self.pointsGrade setAccessibilityLabel:NSLocalizedString(@"Not available", @"Accessibility label for points out of points possible label when points are not availiable.")];
        }
        
        self.letterGrade.text = (assignment && submission) ? [assignment gradeStringForSubmission:submission] : @"—";
        
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
