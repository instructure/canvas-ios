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

@Observable final class NotebookViewModel {

    var listItems: [NotebookListItem] = []

    let router: Router

    private let getCoursesUseCase: GetCoursesUseCase

    private var getCoursesCancellable: AnyCancellable?

    private var searchTextCancellable: AnyCancellable?

    init(router: Router,
         getCoursesUseCase: GetCoursesUseCase) {
        self.router = router
        self.getCoursesUseCase = getCoursesUseCase

        getCoursesCancellable = getCoursesUseCase.get().sink { _ in } receiveValue: { [weak self] courses in
            self?.listItems = courses.map {
                NotebookListItem(institution: $0.institution, course: $0.name)
            }
        }
        onSearch("")
    }

    func onSearch(_ text: String) {
        getCoursesUseCase.search(for: text)
    }

    func onTap(_ listItem: NotebookListItem, viewController: WeakViewController) {
        router.route(
            to: "/notebook/\(listItem.id)",
            from: viewController
        )
    }
}

final class NotebookListItem: Identifiable {
    let institution: String

    let course: String

    var id: String {
        "\(institution)-\(course)"
    }

    init(institution: String, course: String) {
        self.institution = institution
        self.course = course
    }
}
