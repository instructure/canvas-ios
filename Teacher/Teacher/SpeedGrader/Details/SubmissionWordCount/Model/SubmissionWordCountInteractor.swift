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

import Combine
import Core
import Foundation

protocol SubmissionWordCountInteractor {
    func getWordCount(userId: String, attempt: Int) -> AnyPublisher<Int?, Error>
}

final class SubmissionWordCountInteractorLive: SubmissionWordCountInteractor {

    private let assignmentId: String
    private let api: API

    init(assignmentId: String, api: API) {
        self.assignmentId = assignmentId
        self.api = api
    }

    func getWordCount(userId: String, attempt: Int) -> AnyPublisher<Int?, Error> {
        let request = GetSubmissionWordCountRequest(assignmentId: assignmentId, userId: userId)
        return api.makeRequest(request)
            .map { $0.body }
            .map { response in
                let submissionAttempt = response.submissionAttempts.first { $0.node.attempt == attempt }
                guard let submissionAttempt,
                      let wordCount = submissionAttempt.node.wordCount
                else { return nil }

                // This check is needed for now, because API returns non-null `wordCount` values (like zero)
                // for some not currently countable submission types, like "online_upload".
                if submissionAttempt.node.submissionType == SubmissionType.online_text_entry.rawValue {
                    return Int(wordCount)
                }

                return nil
            }
            .eraseToAnyPublisher()
    }
}
