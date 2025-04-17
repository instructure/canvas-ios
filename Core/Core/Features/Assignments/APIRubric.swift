////
//// This file is part of Canvas.
//// Copyright (C) 2019-present  Instructure, Inc.
////
//// This program is free software: you can redistribute it and/or modify
//// it under the terms of the GNU Affero General Public License as
//// published by the Free Software Foundation, either version 3 of the
//// License, or (at your option) any later version.
////
//// This program is distributed in the hope that it will be useful,
//// but WITHOUT ANY WARRANTY; without even the implied warranty of
//// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//// GNU Affero General Public License for more details.
////
//// You should have received a copy of the GNU Affero General Public License
//// along with this program.  If not, see <https://www.gnu.org/licenses/>.
////
//
//import Foundation
//
//// https://canvas.instructure.com/doc/api/assignments.html#RubricCriteria
//public struct APIRubricCriterion: Codable, Equatable {
//    let criterion_use_range: Bool
//    let description: String
//    let id: ID
//    let ignore_for_scoring: Bool?
//    let long_description: String?
//    let points: Double
//    let ratings: [APIRubricRating]?
//}
//
//// https://canvas.instructure.com/doc/api/assignments.html#RubricRating
//public struct APIRubricRating: Codable, Equatable {
//    let description: String
//    let id: ID
//    let long_description: String
//    let points: Double?
//}
//
//public struct APIRubricSettings: Codable, Equatable {
//    var free_form_criterion_comments: Bool?
//    var hide_points: Bool
//    let points_possible: Double?
//}
//
//public typealias RubricID = String
//public typealias APIRubricAssessmentMap = [RubricID: APIRubricAssessment]
//
//// https://canvas.instructure.com/doc/api/rubrics.html#RubricAssessment
//public struct APIRubricAssessment: Codable, Equatable {
//    public static let customRatingId = ""
//
//    /** This is the user entered comment for the rubric. Used when free-form rubric comments are enabled on the assignment. */
//    public let comments: String?
//    /** This is the user entered custom score for the rubric. */
//    public let points: Double?
//    /** This is the selected pre-defined rating for the rubric. Use empty string to reset a rubric's rating to empty. */
//    public let rating_id: String?
//
//    public init(
//        comments: String? = nil,
//        points: Double? = nil,
//        rating_id: String = customRatingId
//    ) {
//        self.comments = comments
//        self.points = points
//        self.rating_id = rating_id
//    }
//}
//
//#if DEBUG
//extension APIRubricCriterion {
//    public static func make(
//        criterion_use_range: Bool = false,
//        description: String = "Effort",
//        id: ID = "1",
//        ignore_for_scoring: Bool? = false,
//        long_description: String? = "Did you even try?",
//        points: Double = 25.0,
//        ratings: [APIRubricRating]? = [ .make() ]
//    ) -> APIRubricCriterion {
//        return APIRubricCriterion(
//            criterion_use_range: criterion_use_range,
//            description: description,
//            id: id,
//            ignore_for_scoring: ignore_for_scoring,
//            long_description: long_description,
//            points: points,
//            ratings: ratings
//        )
//    }
//}
//
//extension APIRubricRating {
//    public static func make(
//        description: String = "Excellent",
//        id: ID = "1",
//        long_description: String = "Like the best!",
//        points: Double? = 25.0
//    ) -> APIRubricRating {
//        return APIRubricRating(
//            description: description,
//            id: id,
//            long_description: long_description,
//            points: points
//        )
//    }
//}
//
//extension APIRubricAssessment {
//    public static func make(
//        comments: String? = "You failed at punctuation!",
//        points: Double? = 25.0,
//        rating_id: String = "1"
//    ) -> APIRubricAssessment {
//        return APIRubricAssessment(
//            comments: comments,
//            points: points,
//            rating_id: rating_id
//        )
//    }
//}
//
//extension APIRubricSettings {
//    public static func make(
//        free_form_criterion_comments: Bool? = false,
//        hides_points: Bool = false,
//        points_possible: Double = 0
//    ) -> APIRubricSettings {
//        return APIRubricSettings(
//            free_form_criterion_comments: free_form_criterion_comments,
//            hide_points: hides_points,
//            points_possible: points_possible
//        )
//    }
//}
//#endif

