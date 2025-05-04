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

class SubmissionListViewModel: ObservableObject {

    enum ViewState: Equatable {
        case initialLoading
        case data
        case empty
        case error
    }

    @Published private(set) var state: ViewState = .initialLoading

    @Published var searchText: String = ""

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
            .combineLatest($searchText.debounce(for: 0.5, scheduler: DispatchQueue.main))
            .map({ (list, searchText) in

                let searchTerm = searchText.lowercased()
                let filtered = searchTerm.isNotEmpty ? list.filter { $0.user?.nameContains(searchTerm) ?? false } : list

                let submitted = filtered.filter { $0.workflowState == .submitted }
                let unsubmitted = filtered.filter { $0.workflowState == .unsubmitted }
                let graded = filtered.filter { $0.isGraded }

                return [
                    SubmissionSection(title: "Submitted", submissions: submitted),
                    SubmissionSection(title: "Not Submitted", submissions: unsubmitted),
                    SubmissionSection(title: "Graded", submissions: graded)
                ]
                .filter({ $0.rows.isNotEmpty })

            })
            .assign(to: &$sections)

        interactor
            .submissions
            .map({ $0.isEmpty ? ViewState.empty : ViewState.data })
            .assign(to: &$state)
    }

    func refresh() async {

        await withCheckedContinuation { continuation in
            interactor
                .refresh()
                .sink {
                    continuation.resume()
                }
                .store(in: &self.subscriptions)
        }
    }
}

// MARK: - Section Model

struct SubmissionSection: Identifiable {
    struct Row: Identifiable {
        let index: Int
        let submission: Submission

        var id: Int { index }
    }

    let title: String
    var rows: [Row]
    var isCollapsed: Bool

    var id: String { title }

    init(title: String, submissions: [Submission], isCollapsed: Bool = false) {
        self.title = title
        self.rows = submissions
            .enumerated()
            .map({ Row(index: $0.offset, submission: $0.element) })
        self.isCollapsed = isCollapsed
    }
}

extension User {

    func nameContains(_ text: String) -> Bool {
        let props = [name, shortName, sortableName].map { $0.lowercased() }
        return props.contains(where: { $0.contains(text.lowercased()) })
    }
}
