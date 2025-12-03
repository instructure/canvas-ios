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

/**
 Tracks whether a submission request is being retried after a previous failure.

 This class maintains state about submission attempts and determines if the current
 submission is a retry of a previously failed submission request. It provides
 thread-safe access to this state for analytics tracking purposes.

 The retrial state is determined by comparing consecutive submission requests:
 - If the same submission request fails, the next attempt is considered a retry
 - If a different submission request is made, the retry state is reset

 ## Usage

 ```swift
 let retrialState = SubmissionRetrialState()

 // Before making a submission request
 retrialState.validate(for: submissionRequest)

 // After receiving a response
 retrialState.report(.succeeded) // or .failed

 // Get analytics parameters
 let params = retrialState.params() // Returns [.retry: 0] or [.retry: 1]
 ```

 ## Thread Safety

 All public methods are thread-safe and use a dedicated dispatch queue for synchronization.
 */
public class SubmissionRetrialState {

    /// Indicates whether the current submission is a retry of a previously failed attempt
    private var inRetrialPhase: Bool = false

    /// The most recent submission request being tracked
    private var request: CreateSubmissionRequest?

    /// Synchronizes access to mutable state across multiple threads
    private let synchronizer = DispatchQueue(label: "Submission state synchronized access")

    public init() {}

    /**
     Validates the submission request and updates the retrial state accordingly.

     Call this method before making a submission request. It compares the new request
     with the previously tracked request:
     - If the requests are the same, the retrial state remains unchanged
     - If the requests differ or no previous request exists, the retrial state is reset to false

     - Parameter anotherRequest: The submission request being validated
     */
    func validate(for anotherRequest: CreateSubmissionRequest) {
        synchronizer.sync {
            validateSync(for: anotherRequest)
        }
    }

    /**
     Reports the outcome of a submission attempt and updates the retrial state.

     Call this method after receiving a response from the submission request:
     - `.succeeded`: Resets the retrial state to false
     - `.failed`: Sets the retrial state to true for the next attempt
     - `.selected`, `.presented`: No state change

     - Parameter phase: The phase of the submission event
     */
    func report(_ phase: Analytics.SubmissionEvent.Phase) {
        synchronizer.sync {
            reportSync(phase)
        }
    }

    /**
     Returns analytics parameters indicating the current retrial state.

     - Returns: A dictionary containing the retry parameter with value 1 if in retrial phase, 0 otherwise
     */
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
