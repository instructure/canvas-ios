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

    @Published public var data: Data = .loading
    @Published public var selectedAssignment: AssignmentPickerViewModel.Assignment?
    public var courseID: String? {
        willSet { courseIdWillChange(to: newValue) }
    }

    private var requestTask: APITask?

    #if DEBUG

    // MARK: - Preview Support

    public init(data: Data) {
        self.data = data
    }

    // MARK: Preview Support -

    #endif

    public init() {
    }

    private func courseIdWillChange(to newValue: String?) {
        // If the same course was selected we don't reload
        if courseID == newValue { return }

        if let newValue = newValue {
            selectedAssignment = nil
            fetchAssignments(for: newValue)
        } else {
            data = .loading
        }
    }

    private func fetchAssignments(for courseID: String) {
        requestTask?.cancel()

        let request = GetAssignmentsRequest(courseID: courseID, perPage: 100)
        requestTask = AppEnvironment.shared.api.makeRequest(request) { assignments, urlResponse, error in
            let newState: Data

            if let assignments = assignments {
                newState = .assignments(Self.filterAssignments(assignments))
            } else {
                let errorMessage = error?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: "")
                newState = .error(errorMessage)
            }

            performUIUpdate {
                self.data = newState
                self.selectDefaultAssignment()
            }
        }
    }

    private static func filterAssignments(_ assignments: [APIAssignment]) -> [Assignment] {
        assignments.compactMap {
            guard $0.isLockedForUser == false, $0.submission_types.contains(.online_upload) else { return nil }
            return Assignment(id: $0.id.value, name: $0.name)
        }
    }

    private func selectDefaultAssignment() {
        guard
            case .assignments(let assignments) = data,
            let defaultAssignmentID = AppEnvironment.shared.userDefaults?.submitAssignmentID,
            let defaultAssignment = assignments.first(where: { $0.id == defaultAssignmentID })
        else { return }

        selectedAssignment = defaultAssignment
    }
}

extension AssignmentPickerViewModel {
    public enum Data {
        case loading
        case error(String)
        case assignments([Assignment])
    }
}
