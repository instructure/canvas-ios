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

struct Submission {
    static let none: String = "none"
    static let on_paper: String = "on_paper"
    static let online_quiz: String = "online_quiz"
    static let discussion_topic: String = "discussion_topic"
    static let external_tool: String = "external_tool"
    static let online_upload: String = "online_upload"
    static let online_text_entry: String = "online_text_entry"
    static let online_url: String = "online_url"

    let id: Int
    let attempt: Int
    let assignmentId: Int
    let userId: Int
    let graderId: Int
    let body: String
    let url: String
    let grade: String
    let previewUrl: String
    let submissionType: String
    let workflowState: String
    let submittedAt: String
    let gradedAt: String
    let score: Double
    let excused: Bool
    let late: Bool
    let gradeMatchesCurrentSubmission: Bool
    let attachments: [Attachment]
    let submissionHistory: [Submission]
    let submissionComments: [SubmissionComment]
}
