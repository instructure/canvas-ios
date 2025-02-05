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

import Foundation
import Observation
import Combine

@Observable
final class FileDetailsViewModel {
    // MARK: - Output

    private(set) var viewState: FileDownloadStatus = .initial
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: DownloadFileInteractor

    // MARK: - Init

    init(interactor: DownloadFileInteractor) {
        self.interactor = interactor
    }

    func downloadFile() {
        viewState = .loading
        interactor.download()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error)  = completion {
                        self?.viewState = .error(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] value in
                    self?.viewState = .loaded(filePath: value)
                }
            )
            .store(in: &subscriptions)
    }
}
