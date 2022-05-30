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

import SwiftUI

public class AssignmentPickerViewModel: ObservableObject {
    public typealias Assignment = IdentifiableName

    @Published public var state: ViewModelState<[Assignment]> = .loading
    @Published public var selectedAssignment: Assignment?
    /** Modify this to trigger the assignment list fetch for the given course ID. */
    public var courseID: String? {
        willSet { courseIdWillChange(to: newValue) }
    }

    private var requestedCourseID: String?

    #if DEBUG

    // MARK: - Preview Support

    public init(state: ViewModelState<[Assignment]>) {
        self.state = state
    }

    // MARK: Preview Support -

    #endif

    public init() {
    }

    public func assignmentSelected(_ assignment: Assignment) {
        Analytics.shared.logEvent("assignment_selected")
        selectedAssignment = assignment
    }

    private func courseIdWillChange(to newValue: String?) {
        // If the same course was selected we don't reload
        if courseID == newValue { return }

        state = .loading

        if let newValue = newValue {
            selectedAssignment = nil
            fetchAssignments(for: newValue)
        }
    }

    private func fetchAssignments(for courseID: String) {
        requestedCourseID = courseID
        let request = AssignmentPickerListRequest(courseID: courseID)

        AppEnvironment.shared.api.makeRequest(request) { response, _, error in
            // If the finished request was for an older fetch we ignore its results
            if self.requestedCourseID != courseID {
                return
            }

            let newState: ViewModelState<[Assignment]>

            if let response = response {
                let assignments = Self.filterAssignments(response.assignments)
                Analytics.shared.logEvent("assignments_loaded", parameters: ["count": assignments.count])
                newState = .data(assignments)
            } else {
                let errorMessage = error?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: "")
                Analytics.shared.logEvent("error_loading_assignments", parameters: ["error": errorMessage])
                newState = .error(errorMessage)
            }

            performUIUpdate {
                self.state = newState
                self.selectDefaultAssignment()
            }
        }
    }

    private static func filterAssignments(_ assignments: [AssignmentPickerListResponse.Assignment]) -> [Assignment] {
        assignments.compactMap {
            guard $0.isLocked == false, $0.submissionTypes.contains(.online_upload) else { return nil }
            return Assignment(id: $0._id, name: $0.name)
        }
    }

    private func selectDefaultAssignment() {
        guard
            case .data(let assignments) = state,
            let defaultAssignmentID = AppEnvironment.shared.userDefaults?.submitAssignmentID,
            let defaultAssignment = assignments.first(where: { $0.id == defaultAssignmentID })
        else { return }

        selectedAssignment = defaultAssignment
    }
}
