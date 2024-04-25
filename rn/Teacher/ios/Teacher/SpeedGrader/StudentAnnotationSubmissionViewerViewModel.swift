//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import Core
import SwiftUI

class StudentAnnotationSubmissionViewerViewModel: ObservableObject {
    @Published public private(set) var session: Result<URL, Error>?

    private var isInitialLoadStarted = false
    private let request: CanvaDocsSessionRequest

    public init(submission: Submission) {
        self.request = CanvaDocsSessionRequest(submissionId: submission.id, attempt: "\(submission.attempt)")
    }

    public func viewDidAppear() {
        if isInitialLoadStarted { return }

        isInitialLoadStarted = true
        initializeAnnotationSession()
    }

    public func retry() {
        session = nil
        initializeAnnotationSession()
    }

    private func initializeAnnotationSession() {
        AppEnvironment.shared.api.makeRequest(request) { [weak self] session, _, error in
            var result: Result<URL, Error>?

            if let session = session?.canvadocs_session_url?.rawValue {
                result = .success(session)
            } else {
                let errorResult = error ?? NSError.instructureError(String(localized: "Unknown Error", bundle: .teacher))
                result = .failure(errorResult)
            }

            performUIUpdate {
                self?.session = result
            }
        }
    }
}
