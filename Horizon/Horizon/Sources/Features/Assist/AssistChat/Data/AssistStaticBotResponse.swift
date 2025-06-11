//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
import Foundation

struct CourseNameAndID: Codable, Equatable {
    let name: String
    let id: String
}

/// These are predefined responses from which a learner can select
enum AssistStaticBotResponse: Codable, Equatable {
    case courseAssistance(_ courseName: String)
    case review
    case selectACourse(_ courses: [CourseNameAndID])

    var text: String {
        switch self {
        case .courseAssistance(let courseName):
            return String(
                format: NSLocalizedString(
                    "How can I help today with the %@ course material?",
                    bundle: .horizon,
                    comment: "Assist chat initial response when only one course is available"
                ),
                courseName
            )
        case .review:
            return String(
                localized: "How would you like to review today?",
                bundle: .horizon
            )
        case .selectACourse:
            return String(
                localized: "Which of your courses would you like to discuss?",
                bundle: .horizon
            )
        }
    }

    var chipOptions: [AssistChipOption] {
        switch self {
        case .courseAssistance:
            return [
                .init(
                    chip: AssistStaticLearnerResponse.review.chip,
                    localResponse: AssistStaticLearnerResponse.review
                )
            ]
        case .review:
            return [
                AssistChipOption(.flashcards),
                AssistChipOption(.quiz)
            ]
        case .selectACourse(let courses):
            return courses.map { course in
                let localResponse: AssistStaticLearnerResponse = .selectCourse(
                    courseName: course.name,
                    courseID: course.id
                )
                return .init(
                    chip: localResponse.chip,
                    localResponse: localResponse
                )
            }
        }
    }
}
