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

public class SubmissionRetrialState {
    private var inRetrialPhase: Bool = false
    private var request: CreateSubmissionRequest?
    private let synchronizer = DispatchQueue(label: "Submission state synchronized access")

    public init() {}

    func validate(for anotherRequest: CreateSubmissionRequest) {
        synchronizer.sync {
            validateSync(for: anotherRequest)
        }
    }

    func report(_ phase: Analytics.SubmissionEvent.Phase) {
        synchronizer.sync {
            reportSync(phase)
        }
    }

    func params() -> [Analytics.SubmissionEvent.Param: Any] {
        return synchronizer.sync {
            return paramsSync()
        }
    }

    private func validateSync(for anotherRequest: CreateSubmissionRequest) {
        guard let request else {
            self.request = anotherRequest
            self.inRetrialPhase = false
            return
        }

        if request != anotherRequest {
            self.request = anotherRequest
            self.inRetrialPhase = false
        }
    }

    private func reportSync(_ phase: Analytics.SubmissionEvent.Phase) {
        switch phase {
        case .succeeded:
            inRetrialPhase = false
        case .failed:
            inRetrialPhase = true
        case .selected, .presented:
            break
        }
    }

    private func paramsSync() -> [Analytics.SubmissionEvent.Param: Any] {
        return [.retry: inRetrialPhase ? 1 : 0]
    }
}
