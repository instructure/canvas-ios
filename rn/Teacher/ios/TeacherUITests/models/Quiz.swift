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

struct Quiz {
    let allowedAttempts: Int
    let assignmentGroupId: Int
    let cantGoBack: Bool
    let description: String
    let dueAt: String
    let hideCorrectAnswersAt: String
    let hideResults: Bool
    let id: Int
    let ipFilter: String
    let lockAt: String
    let oneQuestionAtATime: Bool
    let oneTimeResults: Bool
    let pointsPossible: Double
    let published: Bool
    let questionCount: Int
    let questionTypes: [String]
    let quizType: String
    let scoringPolicy: String
    let showCorrectAnswers: Bool
    let showCorrectAnswersAt: String
    let showCorrectAnswersLastAttempt: Bool
    let shuffleAnswers: Bool
    let timeLimit: Int
    let title: String
    let unlockAt: String
    let unpublishable: Bool
    let questions: [QuizQuestion]
    let assignmentOverrides: [AssignmentOverride]
}
