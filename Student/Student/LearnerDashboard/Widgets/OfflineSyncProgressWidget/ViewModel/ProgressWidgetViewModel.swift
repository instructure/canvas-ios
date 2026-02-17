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

import Foundation
import Combine
import Core

@Observable
final class ProgressWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = ProgressWidgetView
    var config: DashboardWidgetConfig
    var state: InstUI.ScreenState = .data
    var isFullWidth = true
    var isEditable = false

    var layoutIdentifier: [AnyHashable] {
        [uploadState, uploadType]
    }

    private(set) var uploadState: UploadState
    let uploadType: UploadType

    private(set) var progress: Float

    init(
        config: DashboardWidgetConfig,
        uploadState: UploadState,
        uploadType: UploadType,
        progress: Float
    ) {
        self.config = config
        self.uploadState = uploadState
        self.uploadType = uploadType
        self.progress = {
            switch progress {
            case 0...1: progress
            case 1...: 1
            default: 0
            }
        }()
    }

    func makeView() -> ProgressWidgetView {
        ProgressWidgetView(model: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(())
            .map { _ in
                if Bool.random() && self.uploadState == .uploading {
                    self.progress = .random(in: 0...1)
                } else {
                    if self.uploadState == .uploading {
                        self.uploadState = {
                            if case .offlineContent = self.uploadType {
                                .failure
                            } else {
                                Bool.random() ? .success : .failure
                            }
                        }()
                    } else {
                        self.uploadState = .uploading
                        self.progress = .random(in: 0...1)
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

extension ProgressWidgetViewModel {
    enum UploadType: Hashable {
        case offlineContent(courseCount: Int)
        case submission(assignmentName: String)
        case file(fileName: String)
    }

    enum UploadState {
        case uploading
        case success
        case failure
    }
}

#if DEBUG
// Declaring these outside of this file prevents automatic synthesis of numerous protocols
extension ProgressWidgetViewModel.UploadType: CaseIterable, Identifiable {
    static var allCases: [ProgressWidgetViewModel.UploadType] {
        [
            .offlineContent(courseCount: 2),
            .submission(assignmentName: "Battery manufacturing"),
            .file(fileName: "battery_blueprint.jpg")
        ]
    }

    var id: Self {
        self
    }
}

extension ProgressWidgetViewModel.UploadState: CaseIterable, Identifiable {
    var id: Self {
        self
    }
}
#endif
