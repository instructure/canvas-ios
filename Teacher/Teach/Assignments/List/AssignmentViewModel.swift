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
    
    

import AssignmentKit
import SoPersistent
import ReactiveSwift
import SoPretty
import SoLazy
import EnrollmentKit
import TooLegit
import SoIconic

extension Assignment {
    var iconA11yLabel: String {
        switch submissionTypes {
        case [.discussionTopic]:
            return NSLocalizedString("Discussion", comment: "Discussion assignment type")
        case [.quiz]:
            return NSLocalizedString("Quiz", comment: "Title for a quiz submission cell")
        case [.externalTool]:
            return NSLocalizedString("LTI", comment: "LTI tool assignment type")
        default:
            return NSLocalizedString("Assignment", comment: "Plain old assignment (not a quiz or a discussion)")
        }
    }
    
    var gradingStatus: String {
        switch (needsGradingCount, submissionTypes) {
        case (0, [.discussionTopic]):
            return NSLocalizedString("All responses have been graded", comment: "Discussion topic responses have been graded")
        case (1, [.discussionTopic]):
            return NSLocalizedString("1 response needs grading", comment: "only one discussion response needs grading")
        case (let count, [.discussionTopic]):
            return NSLocalizedString("\(count) responses need grading", comment: "N responses need to be graded")
            
        case (0, _):
            return NSLocalizedString("All submissions have been graded", comment: "Assignment grading status")
        case (1, _):
            return NSLocalizedString("1 submission needs grading", comment: "only one item needs to be graded")
        default:
            return NSLocalizedString("\(needsGradingCount) submissions need grading", comment: "More than 1 submission needs grading")
        }
    }
}

func viewModel(for assignment: Assignment, in session: Session) -> ColorfulViewModel {
    let colorful = ColorfulViewModel(features: [.icon, .subtitle])
    
    colorful.title.value = assignment.name
    colorful.icon.value = assignment.icon
    colorful.subtitle.value = assignment.gradingStatus
    colorful.color <~ session.enrollmentsDataSource
        .color(for: .course(withID: assignment.courseID))
    
    return colorful
}
