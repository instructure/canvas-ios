//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

#if DEBUG

import Combine
import Foundation
import UIKit

class FileProgressListViewPreview {
    class PreviewViewModel: FileProgressListViewModelProtocol {
        var dismiss: AnyPublisher<() -> Void, Never> = PassthroughSubject().eraseToAnyPublisher()
        var presentDialog: AnyPublisher<UIAlertController, Never> = PassthroughSubject().eraseToAnyPublisher()
        @Published var items: [FileProgressItemViewModel] = FileProgressItemPreview.files.map { FileProgressItemViewModel(file: $0, onRemove: { _ in }) }
        @Published var state: FileProgressListViewState
        var leftBarButton: BarButtonItemViewModel?
        var rightBarButton: BarButtonItemViewModel?
        var title: String { "Title" }

        init(state: FileProgressListViewState? = nil) {
            self.state = state ?? .waiting

            if state == nil {
                scheduleUpdate()
            }
        }

        private func updateState() {
            switch state {
            case .waiting:
                state = .uploading(progressText: "Uploading 10 MB of 13 MB", progress: 0.66)
            case .uploading:
                state = Bool.random() ? .failed(message: "error happened", error: "unknown error") : .success
            case .failed, .success:
                state = .waiting
            }
            scheduleUpdate()
        }

        private func scheduleUpdate() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (state == .success ? 3 : 1)) { [weak self] in
                self?.updateState()
            }
        }
    }
}

#endif
