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

struct QuizQuestion {
    static let calculatedQuestion = "calculated_question"
    static let essayQuestion = "essay_question"
    static let fileUploadQuestion = "file_upload_question"
    static let multipleBlanksQuestion = "fill_in_multiple_blanks_question"
    static let matchingQuestion = "matching_question"
    static let multipleAnswersQuestion = "multiple_answers_question"
    static let multipleChoiceQuestion = "multiple_choice_question"
    static let multipleDropdownsQuestion = "multiple_dropdowns_question"
    static let numericalQuestion = "numerical_question"
    static let shortAnswerQuestion = "short_answer_question"
    static let textOnlyQuestion = "text_only_question"
    static let trueFalseQuestion = "true_false_question"
    static let exactAnswer = "exact_answer"
    static let rangeAnswer = "range_answer"
    static let precisionAnswer = "precision_answer"

    let answers: [QuizQuestionAnswer]
    let correctComments: String
    let id: Int
    let incorrectComments: String
    let neutralComments: String
    let pointsPossible: Double
    let position: Int
    let questionName: String
    let questionText: String
    let questionType: String
    let quizId: Int
}
