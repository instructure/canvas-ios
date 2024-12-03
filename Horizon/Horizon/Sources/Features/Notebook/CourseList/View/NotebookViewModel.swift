//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Core

@Observable
final class NotebookViewModel {
    // MARK: - Outputs

    var listItems: [NotebookListItem] = []
    let router: Router

    // MARK: - Private variables

    private let getCoursesInteractor: GetCoursesInteractor
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(router: Router, getCoursesInteractor: GetCoursesInteractor) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor

        getCoursesInteractor.get().sink { _ in } receiveValue: { [weak self] courses in
            self?.listItems = courses.map {
                NotebookListItem(id: $0.id, course: $0.course, institution: $0.institution)
            }
        }.store(in: &cancellables)

        onSearch("")
    }

    // MARK: - Inputs

    func onSearch(_ text: String) {
        getCoursesInteractor.search(for: text)
    }

    func onTap(_ listItem: NotebookListItem, viewController: WeakViewController) {
        router.route(
            to: "/notebook/\(listItem.id)",
            from: viewController
        )
    }
}

struct NotebookListItem: Identifiable {
    let id: String

    let course: String

    let institution: String
}
