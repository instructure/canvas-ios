//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct ReportBugFormValidator {
    private(set) var topicError: String?
    private(set) var subjectError: String?
    private(set) var descriptionError: String?
    private(set) var isValid: Bool = false

    mutating func validationErrors(
        selectedTopic: String,
        subject: String,
        description: String
    ) {
        topicError = selectedTopic.trimmedEmptyLines.isEmpty
        ? String(localized: "Select a topic")
        : nil

        subjectError = subject.trimmedEmptyLines.isEmpty
        ? String(localized: "Enter a subject")
        : nil

        descriptionError = description.trimmedEmptyLines.isEmpty
        ? String(localized: "Enter a description")
        : nil

        isValid = topicError == nil && subjectError == nil && descriptionError == nil
    }
}
