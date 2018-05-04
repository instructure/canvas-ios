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

import Foundation

enum EnrollmentType: String, Codable {
    case student
}

struct Enrollment: Codable {
    let type: String
    var enrollmentType: EnrollmentType? {
        return EnrollmentType(rawValue: type)
    }

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        self.enrollments = try container.decodeIfPresent([Enrollment].self, forKey: .enrollments) ?? []
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
        guard let enrollment = enrollments.filter({ $0.enrollmentType == .student }).first else {
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
