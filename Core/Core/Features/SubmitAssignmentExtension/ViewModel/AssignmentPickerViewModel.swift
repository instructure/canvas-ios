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
    public struct AlertMessage: Identifiable {
        public var id: String { message }
        public let message: String
    }
    public typealias State = ViewModelState<[AssignmentPickerItem]>

    // MARK: - Outputs
    @Published public private(set) var state: State = .loading
    @Published public private(set) var selectedAssignment: AssignmentPickerItem?
    @Published public var incompatibleFilesMessage: AlertMessage?
    @Published public var endCursor: String?

    public private(set) var dismissViewDidTrigger = PassthroughSubject<Void, Never>()
    /** Modify this to trigger the assignment list fetch for the given course ID. */
    public var courseID: String? {
        willSet { courseIdWillChange(to: newValue) }
    }
    /** Until we know what files the user wants to share we don't allow assignment selection so we can correctly filter out incompatible assignments. */
    public let sharedFileExtensions = CurrentValueSubject<Set<String>?, Never>(nil)

    // MARK: - Properties
    private let service: AssignmentPickerListServiceProtocol
    private var serviceSubscription: AnyCancellable?

    #if DEBUG

    // MARK: - Preview Support

    public init(state: ViewModelState<[AssignmentPickerItem]>) {
        self.state = state
        self.service = AssignmentPickerListService()
    }

    // MARK: Preview Support -

    #endif

    public init(service: AssignmentPickerListServiceProtocol = AssignmentPickerListService()) {
        self.service = service
        self.serviceSubscription = service.result
            .combineLatest(sharedFileExtensions) { result, sharedExtensions -> State in
                guard var sharedExtensions = sharedExtensions else { return .loading }
                sharedExtensions = Set(sharedExtensions.map { $0.lowercased() })

                switch result {
                case .success(let items): return .data(items.map { AssignmentPickerItem(apiItem: $0, sharedFileExtensions: sharedExtensions) })
                case .failure(let error): return .error(error.localizedDescription)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
                self?.selectDefaultAssignment()
            }

        service.endCursor
            .receive(on: DispatchQueue.main)
            .assign(to: &$endCursor)
    }

    public func assignmentSelected(_ assignment: AssignmentPickerItem) {
        Analytics.shared.logEvent("assignment_selected")

        if let notAvailableReason = assignment.notAvailableReason {
            incompatibleFilesMessage = AlertMessage(message: notAvailableReason)
        } else {
            selectedAssignment = assignment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dismissViewDidTrigger.send()
            }
        }
    }

    public func loadNextPage(completion: (() -> Void)? = nil) {
        Analytics.shared.logEvent("assignment_picker_load_next_page")
        service.loadNextPage(completion: completion)
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
