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

    public enum PhasedEventSubmissionType: String {
        case media_recording, text_entry, file_upload, url, annotation, studio
    }

    public enum SubmissionPhase: String {
        case selected
        case presented // only valid for annotation type
        case succeeded
        case failed
    }

    public enum SubmissionDetail: String {
        case discussion, quiz
    }

    public enum SubmissionEvent {
        public enum Param: String {
            case attempt
            case error
            case media_type
            case media_source
        }

        case phase(SubmissionPhase, PhasedEventSubmissionType, Int?)
        case detail(SubmissionDetail)
        case lti
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

extension SubmissionType {

    public func asAnalyticsPhasedEventType() -> Analytics.PhasedEventSubmissionType? {
        switch self {
        case .media_recording:
            return .media_recording
        case .online_text_entry:
            return .text_entry
        case .online_upload:
            return .file_upload
        case .online_url:
            return .url
        case .student_annotation:
            return .annotation
        default:
            return nil
        }
    }
}

public extension FilePickerSource {
    var analyticsValue: String {
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
            return "assignment_submit_selected"
        case .lti:
            return "assignment_launchlti_selected"
        case .detail(let type):
            return "assignment_detail_\(type.rawValue)launch"
        case .phase(let phase, let type, _):
            let cleanName = type.rawValue.replacingOccurrences(of: "_", with: "")
            return "submit_\(cleanName)_\(phase.rawValue)"
        }
    }

    var params: [Param: Any]? {
        if case .phase(_, _, let attempt) = self, let attempt {
            return [.attempt: attempt]
        } else {
            return nil
        }
    }
}
