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

import SwiftUI

public protocol FileProgressListViewModelProtocol: ObservableObject {
    var items: [FileProgressItemViewModel] { get }
    var state: FileProgressListViewState { get }
    var leftBarButton: BarButtonItemViewModel? { get }
    var rightBarButton: BarButtonItemViewModel? { get }
    var title: String { get }

    func setupViewEnvironment(env: AppEnvironment, controller: WeakViewController)
}

public enum FileProgressListViewState: Equatable, Identifiable {
    case waiting
    case uploading(progressText: String, progress: Float)
    case failed
    case success

    public var id: String {
        switch self {
        case .waiting: return "waiting"
        case .uploading(let progressText, let progress): return "uploading(\(progressText), \(progress))"
        case .failed: return "failed"
        case .success: return "success"
        }
    }
}

public struct BarButtonItemViewModel {
    public let title: String
    public let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}
