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

import Combine
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
final class MyAssignmentSubmissionsViewModel {
    // MARK: - Private Properties

    private var subscription: AnyCancellable?

    // MARK: - Output

    private(set) var viewState: FileDownloadStatus = .initial

    // MARK: - Dependencies

    private let interactor: DownloadFileInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: DownloadFileInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
    }

    // MARK: - Input Functions

    func downloadFile(viewController: WeakViewController, file: File) {
        viewState = .loading
        subscription = interactor
            .download(file: file)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.viewState = .error(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] url in
                    self?.viewState = .initial
                    self?.showShareSheet(fileURL: url, viewController: viewController)
                }
            )
    }

    func cancelDownload() {
        subscription?.cancel()
        viewState = .initial
    }

    // MARK: - Private Functions

    private func showShareSheet(fileURL: URL, viewController: WeakViewController) {
        let controller = CoreActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        router.show(controller, from: viewController, options: .modal())
    }
}
