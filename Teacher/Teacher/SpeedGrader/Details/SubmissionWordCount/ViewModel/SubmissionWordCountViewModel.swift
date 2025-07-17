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
import CombineExt
import SwiftUI

final class SubmissionWordCountViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var wordCount: String = ""
    @Published private(set) var hasContent: Bool = false

    // MARK: - Inputs

    let didChangeAttempt = PassthroughSubject<Int, Never>()

    // MARK: - Private

    private let userId: String
    private let interactor: SubmissionWordCountInteractor

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        userId: String,
        attempt: Int,
        interactor: SubmissionWordCountInteractor
    ) {
        self.userId = userId
        self.interactor = interactor

        updateWordCount(on: didChangeAttempt)
        updateWordCount(attempt: attempt)
    }

    private func updateWordCount(on publisher: PassthroughSubject<Int, Never>) {
        publisher
            .sink { [weak self] attempt in
                self?.updateWordCount(attempt: attempt)
            }
            .store(in: &subscriptions)
    }

    private func updateWordCount(attempt: Int) {
        interactor.getWordCount(userId: userId, attempt: attempt)
            .replaceError(with: nil)
            .map { $0.flatMap(String.init) ?? "" }
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.wordCount = $0
                self?.hasContent = $0.isNotEmpty
            }
            .store(in: &subscriptions)
    }
}
