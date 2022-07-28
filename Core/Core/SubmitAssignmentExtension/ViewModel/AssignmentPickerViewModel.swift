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

import Combine
import SwiftUI

public class AssignmentPickerViewModel: ObservableObject {
    public typealias State = ViewModelState<[AssignmentPickerListItem]>
    @Published public private(set) var state: State = .loading
    @Published public private(set) var selectedAssignment: AssignmentPickerListItem?
    /** Modify this to trigger the assignment list fetch for the given course ID. */
    public var courseID: String? {
        willSet { courseIdWillChange(to: newValue) }
    }

    /** Until we know what files the user wants to share we don't allow assignment selection so we can correctly filter out incompatible assignments. */
    private var sharedFilesReady = false
    private let service: AssignmentPickerListServiceProtocol
    private var serviceSubscription: AnyCancellable?

    #if DEBUG

    // MARK: - Preview Support

    public init(state: ViewModelState<[AssignmentPickerListItem]>) {
        self.state = state
        self.service = AssignmentPickerListService()
    }

    // MARK: Preview Support -

    #endif

    public init(service: AssignmentPickerListServiceProtocol = AssignmentPickerListService()) {
        self.service = service
        self.serviceSubscription = service.result
            .map { result -> State in
                switch result {
                case .success(let items): return State.data(items)
                case .failure(let error): return State.error(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
                self?.selectDefaultAssignment()
            }
    }

    public func assignmentSelected(_ assignment: AssignmentPickerListItem) {
        Analytics.shared.logEvent("assignment_selected")
        selectedAssignment = assignment
    }

    private func courseIdWillChange(to newValue: String?) {
        // If the same course was selected we don't reload
        if courseID == newValue { return }

        state = .loading

        if let newValue = newValue {
            selectedAssignment = nil
            service.courseID = newValue
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
