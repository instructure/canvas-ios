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

extension Analytics {

    public enum SubmissionEvent {
        case phase(Phase, PhasedType, Int?)
        case detail(Detail)
        case start
    }

    public func logSubmission(_ event: SubmissionEvent, additionalParams: [SubmissionEvent.Param: Any]? = nil) {
        let allParams = (event.params ?? [:])
            .merging(additionalParams ?? [:], uniquingKeysWith: { $1 })
            .nilIfEmpty?
            .reduce(into: [String: Any]()) { partialResult, pair in
                partialResult[pair.key.rawValue] = pair.value
            }

        logEvent(event.analyticsEventName, parameters: allParams)
    }
}

extension Analytics.SubmissionEvent {

    public enum PhasedType: String {
        case mediaRecording
        case textEntry
        case fileUpload
        case url
        case annotation
        case studio
    }

    public enum Phase: String {
        case selected
        case presented // only valid for annotation type
        case succeeded
        case failed
    }

    public enum Detail: String {
        case discussion
        case classicQuiz
        case newQuiz
        case lti
    }

    public enum Param: String {
        case attempt
        case error
        case media_type
        case media_source
        case retry
    }
}

extension SubmissionType {

    public var analyticsValue: Analytics.SubmissionEvent.PhasedType? {
        switch self {
        case .media_recording:
            return .mediaRecording
        case .online_text_entry:
            return .textEntry
        case .online_upload:
            return .fileUpload
        case .online_url:
            return .url
        case .student_annotation:
            return .annotation
        case .discussion_topic,
                .external_tool,
                .none,
                .not_graded,
                .online_quiz,
                .on_paper,
                .basic_lti_launch,
                .wiki_page:
            return nil
        }
    }
}

extension FilePickerSource {

    public var analyticsValue: String {
        switch self {
        case .camera:
            return "camera"
        case .library:
            return "library"
        case .files:
            return "files"
        case .audio:
            return "audio_recorder"
        case .documentScan:
            return "document_scanner"
        }
    }
}

private extension Analytics.SubmissionEvent {

    var analyticsEventName: String {
        switch self {
        case .start:
            return "assignmentDetails_submitButton_selected"
        case .detail(let type):
            return "assignmentDetails_\(type.rawValue)_opened"
        case .phase(let phase, let type, _):
            return "submit_\(type.rawValue)_\(phase.rawValue)"
        }
    }

    var params: [Param: Any]? {
        if case .phase(_, _, let attempt) = self, let attempt {
            return [.attempt: attempt, .retry: 0]
        } else {
            return [.retry: 0]
        }
    }
}
