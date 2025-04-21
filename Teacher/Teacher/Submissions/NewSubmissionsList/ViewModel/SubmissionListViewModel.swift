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

import Core
import Foundation
import Combine

struct SubmissionSection: Identifiable {
    let title: String
    var submissions: [Submission]
    var isCollapsed: Bool = false

    var id: String { title }
}

class SubmissionListViewModel: ObservableObject {

    enum ViewState: Equatable {
        case initialLoading
        case data
        case empty
        case error
    }

    @Published private(set) var state: ViewState = .initialLoading

    @Published var assignment: Assignment?
    @Published var submissions: [Submission] = []
    @Published var sections: [SubmissionSection] = []

    private let interactor: SubmissionListInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: SubmissionListInteractor) {
        self.interactor = interactor

        interactor.assignment.assign(to: &$assignment)
        interactor.submissions.assign(to: &$submissions)

        interactor
            .submissions
            .map({ list in
                let submitted = list.filter { $0.workflowState == .submitted }
                let unsubmitted = list.filter { $0.workflowState == .unsubmitted }
                let graded = list.filter { $0.isGraded }

                return [
                    SubmissionSection(title: "Submitted", submissions: submitted),
                    SubmissionSection(title: "Not Submitted", submissions: unsubmitted),
                    SubmissionSection(title: "Graded", submissions: graded)
                ]
                .filter({ $0.submissions.isNotEmpty })
            })
            .assign(to: &$sections)

        interactor
            .submissions
            .map({ $0.isEmpty ? ViewState.empty : ViewState.data })
            .assign(to: &$state)
    }
}
