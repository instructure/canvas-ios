//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import AssignmentKit
import UIKit

public enum GradeViewModel {
    
    case none
    case awaitingGrade
    case ungraded
    case letterGradeOrGPA(String, points: Double, possible: Double)
    case points(points: Double, possible: Double)
    case percent(String, points: Double, possible: Double)
    case completeOrIncomplete(String, points: Double, possible: Double)
    
    public func detailsWithFormatter(_ formatter: (Double)->String) -> (grade: String, gradeDetails: String, circlePercent: CGFloat, gradeLabelOffset: CGFloat) {
        var details = (
            grade: "",
            gradeDetails: "",
            circlePercent: CGFloat(0.0),
            gradeLabelOffset: CGFloat(-21.0)
        )
        
        switch self {
        case .none:
            details.gradeLabelOffset = 0.0
            
        case .awaitingGrade:
            details.grade = formatter(0.0)
            details.gradeDetails = NSLocalizedString("Awaiting Grade", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment hasn't been graded yet but can be graded")
            details.circlePercent = CGFloat(0.0/1.0)
            
        case .ungraded:
            details.grade = NSLocalizedString("Ungraded", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment is not graded")
            details.gradeLabelOffset = 0.0
            
        case let .letterGradeOrGPA(grade, points, possible):
            details.grade = grade
            details.gradeDetails = NSLocalizedString("\(formatter(points)) of \(formatter(possible))", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "grade details for points based grade i.e. \"10 of 12\"")
            details.circlePercent = possible <= 0 ? 0.0 : CGFloat(points/possible)
            
        case let .points(points, possible):
            details.grade = formatter(points) 
            details.gradeDetails = NSLocalizedString(" of \(formatter(possible))", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "grade details for points based grade i.e. \"10 of 12\"")
            details.circlePercent = possible <= 0 ? 0.0 : CGFloat(points/possible)
            
        case let .percent(percentText, points, possible):
            details.grade = percentText
            details.gradeDetails = NSLocalizedString("\(formatter(points)) of \(formatter(possible))", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "grade details for points based grade i.e. \"10 of 12\"")
            details.circlePercent = possible <= 0 ? 0.0 : CGFloat(points/possible)
            
        case let .completeOrIncomplete(label, points, possible):
            details.grade = label.capitalized
            details.gradeDetails = NSLocalizedString("\(formatter(points)) of \(formatter(possible))", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "grade details for points based grade i.e. \"10 of 12\"")
            details.circlePercent = possible <= 0 ? 0.0 : CGFloat(points/possible)
        }
        return details
    }
    
    func updateGradeView(_ view: CircularGradeView, animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        let details = detailsWithFormatter({ CircularGradeView.numberFormatter.string(from: NSNumber(value: $0)) ?? "" } )
        view.gradeLabel.text = details.grade
        view.gradeDetailLabel.text = details.gradeDetails
        view.gradeLayer.strokeEnd = details.circlePercent
        view.gradeLabelOffsetConstraint.constant = details.gradeLabelOffset
        CATransaction.commit()
    }
    
    public static func gradeViewModelForAssignment(_ assignment: Assignment) -> GradeViewModel {
        var grade = GradeViewModel.none
        
        
        if (assignment.gradedAt == nil && assignment.gradingType != .notGraded) {
            grade = .awaitingGrade
            return grade
        }
        
        
        let currentScore = assignment.currentScore?.doubleValue ?? 0
        switch assignment.gradingType {
        case .notGraded:
            grade = .ungraded
        case .letterGrade, .gpaScale:
            let letterGrade = assignment.currentGrade 
            grade = .letterGradeOrGPA(letterGrade, points: currentScore, possible: assignment.pointsPossible)
        case .passFail:
            let completeIncomplete = assignment.currentGrade 
            grade = .completeOrIncomplete(completeIncomplete, points: currentScore, possible: assignment.pointsPossible)
        case .percent:
            let letterGrade = assignment.currentGrade 
            grade = .percent(letterGrade, points: currentScore, possible: assignment.pointsPossible)
        case .points:
            grade = .points(points: currentScore, possible: assignment.pointsPossible)
        default: print("Error this shouldn't happen")
        }
        
        return grade
    }
}

// MARK: - Equatable

extension GradeViewModel: Equatable {}
public func ==(lhs: GradeViewModel, rhs: GradeViewModel) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none), (.awaitingGrade, .awaitingGrade), (.ungraded, .ungraded):
        return true
    case let (.letterGradeOrGPA(grade1, points1, possible1), .letterGradeOrGPA(grade2, points2, possible2)):
        return grade1 == grade2 && points1 == points2 && possible1 == possible2
    case let (.points(points1, possible1), .points(points2, possible2)):
        return points1 == points2 && possible1 == possible2
    case let (.percent(text1, points1, possible1), .percent(text2, points2, possible2)):
        return text1 == text2 && points1 == points2 && possible1 == possible2
    case let (.completeOrIncomplete(label1, points1, possible1), .completeOrIncomplete(label2, points2, possible2)):
        return label1 == label2 && points1 == points2 && possible1 == possible2
    default: return false
    }
}

