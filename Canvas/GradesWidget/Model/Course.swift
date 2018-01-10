//
//  Course.swift
//  GradesWidget
//
//  Created by Nathan Armstrong on 1/9/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation

struct Enrollment: Codable {
    enum EnrollmentType: String, Codable {
        case student
    }

    let type: EnrollmentType?

    let computedCurrentGrade: String?
    let computedCurrentScore: Double?

    let multipleGradingPeriodsEnabled: Bool?
    let currentPeriodComputedCurrentGrade: String?
    let currentPeriodComputedCurrentScore: Double?

    enum CodingKeys: String, CodingKey {
        case type
        case computedCurrentGrade = "computed_current_grade"
        case computedCurrentScore = "computed_current_score"
        case multipleGradingPeriodsEnabled = "multiple_grading_periods_enabled"
        case currentPeriodComputedCurrentGrade = "current_period_computed_current_grade"
        case currentPeriodComputedCurrentScore = "current_period_computed_current_score"
    }
}

struct Course: Codable {
    let id: String
    let name: String
    let isFavorite: Bool
    let enrollments: [Enrollment]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isFavorite = "is_favorite"
        case enrollments
    }

    static let scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.decimalSeparator = "."
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 3
        formatter.roundingMode = .down
        return formatter
    }()

    var displayGrade: String {
        guard let enrollment = enrollments.filter({ $0.type == .student }).first else {
            return ""
        }

        let createDisplay = { (score: Double?, grade: String?) -> String in
            let emptyDisplay = "N/A"

            guard let scoreNumber = score.flatMap(NSNumber.init), let scoreString = Course.scoreFormatter.string(from: scoreNumber) else {
                // Odd scenario where there isn't a score (or it's not a number)
                return grade ?? emptyDisplay
            }

            if let grade = grade {
                return "\(scoreString) - \(grade)"
            }

            return scoreString
        }

        if let mgpEnabled = enrollment.multipleGradingPeriodsEnabled, mgpEnabled {
            return createDisplay(enrollment.currentPeriodComputedCurrentScore, enrollment.currentPeriodComputedCurrentGrade)
        }

        return createDisplay(enrollment.computedCurrentScore, enrollment.computedCurrentGrade)
    }
}
