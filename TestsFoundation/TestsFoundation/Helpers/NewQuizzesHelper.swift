//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class NewQuizzesHelper: BaseHelper {
    @discardableResult
    public static func createNewQuiz(course: DSCourse,
                                     title: String = "The Great New Quiz",
                                     instructions: String = "Do it right!") -> DSNewQuiz {
        return seeder.createNewQuiz(courseId: course.id, quizBody: .init(title: title, instructions: instructions))
    }

    @discardableResult
    public static func createTrueFalseNewQuizItem(course: DSCourse,
                                                  quiz: DSNewQuiz,
                                                  title: String = "The Great Question",
                                                  question: String = "Is the NewQuiz API overcomplicated?") -> DSNewQuizItem {
        let quizItemBody = CreateDSNewQuizItemRequest.RequestedDSNewQuizItem(
            entry: .init(
                title: title, item_body: question, interaction_type_slug: .trueFalse,
                interaction_data: .init(true_choice: "RIGHT!", false_choice: "WRONG!")),
            scoring_data: .init(value: true),
            scoring_algorithm: .trueFalse)
        return seeder.createNewQuizItem(courseId: course.id, quizId: quiz.id, quizItemBody: quizItemBody)
    }

    @discardableResult
    public static func enableFeatureFlagForCourse(course: DSCourse,
                                                  feature: DSFeature,
                                                  state: DSFeatureFlagState = .on) -> DSFeatureFlag {
        return seeder.setFeatureFlag(courseId: course.id, feature: feature, state: state)
    }

    @discardableResult
    public static func listFeaturesForCourse(course: DSCourse) -> [DSFeature] {
        return seeder.getFeatures(courseId: course.id)
    }

    @discardableResult
    public static func listFeaturesForAccount(course: DSCourse) -> [DSFeature] {
        return seeder.getFeatures(courseId: course.id, accountId: course.account_id)
    }
}
