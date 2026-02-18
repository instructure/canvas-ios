//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Core
import CoreData
import Foundation
import SwiftUI

@Observable
final class FileUploadProgressWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = FileUploadProgressWidgetView

    // MARK: - Protocol Properties

    let config: DashboardWidgetConfig
    private(set) var state: InstUI.ScreenState = .empty
    let isFullWidth = true
    let isEditable = false

    var layoutIdentifier: [AnyHashable] {
        uploadCards.map(\.id)
    }

    // MARK: - Public Properties

    private(set) var uploadCards: [FileUploadCardState] = []

    // MARK: - Private Properties

    private let listViewModel: FileUploadNotificationCardListViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(config: DashboardWidgetConfig, listViewModel: FileUploadNotificationCardListViewModel) {
        self.config = config
        self.listViewModel = listViewModel
        setupObserver()
    }

    private func setupObserver() {
        listViewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.uploadCards = items.map { item in
                    FileUploadCardState(
                        id: item.id.uriRepresentation().absoluteString,
                        assignmentName: item.assignmentName,
                        state: self.mapState(item.state),
                        progress: self.calculateProgress(for: item)
                    )
                }
                self.state = self.uploadCards.isEmpty ? .empty : .data
            }
            .store(in: &subscriptions)
    }

    private func calculateProgress(for item: FileUploadNotificationCardItemViewModel) -> Float? {
        guard case .uploading = item.state else { return nil }
        guard let submission = listViewModel.fileSubmissions.first(where: { $0.objectID == item.id }) else {
            return nil
        }
        let totalSize = submission.totalSize
        guard totalSize > 0 else { return 0 }
        return Float(submission.totalUploadedSize) / Float(totalSize)
    }

    private func mapState(_ state: FileUploadNotificationCardItemViewModel.State) -> FileUploadCardState.UploadState {
        switch state {
        case .uploading: return .uploading
        case .success: return .success
        case .failure: return .failed
        }
    }

    func dismiss(uploadId: String) {
        guard let item = listViewModel.items.first(where: { $0.id.uriRepresentation().absoluteString == uploadId }) else {
            return
        }
        item.hideDidTap()
    }

    func makeView() -> FileUploadProgressWidgetView {
        FileUploadProgressWidgetView(model: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        listViewModel.sceneDidBecomeActive.send()
        return Just(()).eraseToAnyPublisher()
    }
}
