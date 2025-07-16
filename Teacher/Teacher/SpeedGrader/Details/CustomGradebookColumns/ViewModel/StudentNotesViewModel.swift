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
import Combine
import SwiftUI

final class StudentNotesViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var entries: [StudentNotesEntry] = []

    // MARK: - Private properties

    private let interactor: CustomGradebookColumnsInteractor

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        userId: String,
        interactor: CustomGradebookColumnsInteractor
    ) {
        self.interactor = interactor

        interactor.getStudentNotesEntries(userId: userId)
            .receive(on: RunLoop.main)
            .replaceError(with: []) // TODO: error handling
            .assign(to: \.entries, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
}
