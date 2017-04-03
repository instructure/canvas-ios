/*
 * Copyright (C) 2017 - present Instructure, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/* This is an auto-generated file. */

struct Assignment {
    // let allDates: [String] // trailing comma
    // let allowedExtensions: [String] // trailing comma
    let anonymousSubmissions: Bool
    let assignmentGroupId: Int
    // let assignmentVisibility: [Int] // trailing comma
    let automaticPeerReviews: Bool
    let courseId: Int
    let createdAt: String
    let description: String
    // let discussionTopic: Int // may be null
    let dueAt: String
    let gradeGroupStudentIndividually: Bool
    // let gradingStandardId: Int // may be null
    let gradingType: String
    // let groupCategoryId: Int // may be null
    let hasOverrides: Bool
    let htmlUrl: String
    let id: Int
    let lockAt: String
    let muted: Bool
    let name: String
    let needsGradingCount: Int
    // let needsGradingCountBySection: [Int] // trailing comma
    let onlyVisibileToOverrides: Bool
    // overrides // model not yet defined
    // let peerReviewCount: Int // may be null
    let peerReviews: Bool
    // let peerReviewsAssignAt: String // may be null
    let pointsPossible: Int
    let position: Int
    let published: Bool
    // let quizId: Int // may be null
    // rubric // model not yet defined
    // rubric_settings // model not yet defined
    // let submissionTypes: [String] // trailing comma
    let unlockAt: String
    let unpublishable: Bool
    let updatedAt: String
    let useRubricForGrading: Bool
}
