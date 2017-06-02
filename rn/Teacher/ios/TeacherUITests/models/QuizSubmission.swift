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

struct QuizSubmission {
    static let untaken = "untaken"
    static let pending_review = "pending_review"
    static let complete = "complete"
    static let settings_only = "settings_only"
    static let preview = "preview"

    let id: Int
    let quizId: Int
    let quizVersion: Int
    let userId: Int
    let submissionId: Int
    let score: Double
    let keptScore: Double
    let startedAt: String
    let endAt: String
    let finishedAt: String
    let attempt: Int
    let workflowState: String
    let fudgePoints: Int
    let quizPointsPossible: Double
    let extraAttempts: Int
    let manuallyUnlocked: Bool
    let validationToken: String
    let scoreBeforeRegrade: Double
    let seenResults: Bool
    let timeSpent: Int
    let attemptsLeft: Int
    let overdueAndNeedsSubmission: Bool
    let excused: Bool
    let htmlUrl: String
}
