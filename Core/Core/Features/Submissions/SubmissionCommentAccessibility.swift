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

extension SubmissionComment {
    public var accessibilityLabelForHeader: String {
        if let attempt {
            let attemptString = String.localizedAttemptNumber(attempt)
            let submissionInfo = String.localizedStringWithFormat(
                String(localized: "Submitted by %1$@, on %2$@", bundle: .core, comment: "Submitted by John Doe, on 1948.12.02. at 11:42"),
                authorName,
                createdAtLocalizedString
            )
            return "\(attemptString), \(submissionInfo)"
        }

        if let mediaType, mediaURL != nil {
            let format = switch mediaType {
            case .audio:
                String(localized: "%1$@ left an audio comment on %2$@", bundle: .core, comment: "John Doe left an audio comment on 1948.12.02. at 11:42")
            case .video:
                String(localized: "%1$@ left a video comment on %2$@", bundle: .core, comment: "John Doe left a video comment on 1948.12.02. at 11:42")
            }
            return String.localizedStringWithFormat(
                format,
                authorName,
                createdAtLocalizedString
            )
        }

        return String.localizedStringWithFormat(
            String(localized: "%1$@ commented on %2$@: %3$@", bundle: .core, comment: "John Doe commented on 1948.12.02. at 11:42: This is my comment"),
            authorName,
            createdAtLocalizedString,
            comment
        )
    }

    public func accessibilityLabelForAttempt(submission: Submission) -> String {
        [
            String.localizedAttemptNumber(submission.attempt),
            submission.attemptAccessibilityDescription
        ].joined(separator: ", ")
    }

    public func accessibilityLabelForCommentAttachment(_ file: File) -> String {
        [
            String(localized: "Attached file", bundle: .core, comment: "Describes an attached file, not the act of attaching."),
            file.displayName,
            file.size.humanReadableFileSize
        ].joined(separator: ", ")
    }

    public func accessibilityLabelForAttemptAttachment(_ file: File, submission: Submission) -> String {
        [
            String.localizedAttemptNumber(submission.attempt),
            submission.attemptAccessibilityDescription,
            file.displayName,
            file.size.humanReadableFileSize
        ].joined(separator: ", ")
    }
}
