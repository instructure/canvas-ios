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
enum AssistStaticBotResponse {
    case courseAssistance(_ courseName: String, pageContext: AssistChatPageContext?)
    case review
    case selectACourse(_ courses: [CourseNameAndID], pageContext: AssistChatPageContext? = nil)

    var chipOptions: [AssistChipOption] {
        switch self {
        case .courseAssistance(_, let pageContext):
            if pageContext == nil {
                return [AssistChipOption.init(assistStaticLearnerResponse: .answerQuestion)]
            }
            return [
                AssistChipOption.init(assistStaticLearnerResponse: .flashCards),
                AssistChipOption.init(assistStaticLearnerResponse: .quiz),
                AssistChipOption.init(assistStaticLearnerResponse: .answerQuestion)
            ]
        case .review:
            return [
                AssistChipOption(.flashcards),
                AssistChipOption(.quiz)
            ]
        case .selectACourse(let courses, let pageContext):
            return courses.map { course in
                let localResponse: AssistStaticLearnerResponse = .selectCourse(
                    courseName: course.name,
                    courseID: course.id,
                    pageContext: pageContext
                )
                return .init(
                    chip: localResponse.chip,
                    localResponse: localResponse
                )
            }
        }
    }

    var prompt: String? {
        switch self {
        case .selectACourse(let courses, _):
            var jsonCourses = "[]"
            if let jsonData = try? JSONEncoder().encode(courses),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonCourses = jsonString
            }
            return """
                The user has been asked to select from a list of courses. Those course names and IDs in JSON are [\(jsonCourses)]. Based on the user response select one or none of the courses. If you select one of the listed courses, return the JSON of the course you think they've asked for. It's OK if what the user types is not exact but it should be close. If the user's response does not resemble any of the course names, return an empty string. Only include the JSON in the response, nothing else. Do not include any additional text or explanation.
            """
        case .review:
            return """
                The user has been asked how they would like to review today. Based on the user response, select one of the following options: flashcards or quiz. If the user's response does not resemble either option, return an empty string. Only include the selected option in the response, nothing else. Do not include any additional text or explanation.
            """
        default:
            return nil
        }
    }

    func responseHandler(response: String, assistDataEnvironment: AssistDataEnvironment) -> AssistChatMessage? {
        switch self {
        case .selectACourse(let courses, _):
            if let data = response.data(using: .utf8),
               let course = try? JSONDecoder().decode(CourseNameAndID.self, from: data) {
                assistDataEnvironment.setCourseID(course.id)
                return AssistChatMessage(
                    staticResponse: .courseAssistance(
                        course.name,
                        pageContext: assistDataEnvironment.pageContext.value
                    )
                )
            }
            return AssistChatMessage(staticResponse: .selectACourse(courses))
        case .review:
            if response.lowercased().contains("flashcards") {
                return AssistChatMessage(userResponse: "Flashcards")
            } else if response.lowercased().contains("quiz") {
                return AssistChatMessage(userResponse: "Quiz")
            }
            return nil
        default:
            return nil
        }
    }

    var service: DomainService.Option? {
        switch self {
        case .review:
            return .cedar
        default:
            return nil
        }
    }

    var text: String {
        switch self {
        case .courseAssistance(let courseName, _):
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
}
