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
    var term: String = "" {
        didSet {
            getCoursesInteractor.setTerm(term)
        }
    }

    // MARK: - Private variables

    private let getCoursesInteractor: GetNoteCoursesInteractor
    private let router: Router
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Init

    init(router: Router, getCoursesInteractor: GetNoteCoursesInteractor) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor

        getCoursesInteractor.get()
            .flatMap {
                $0.publisher
                    .map { course in
                        NotebookListItem(
                            id: course.id,
                            course: course.course,
                            institution: course.institution
                        )
                    }
                    .collect()
            }
            .replaceError(with: [])
            .sink { [weak self] in
                self?.listItems = $0
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func onBack(viewController: WeakViewController) {
        router.pop(from: viewController)
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
