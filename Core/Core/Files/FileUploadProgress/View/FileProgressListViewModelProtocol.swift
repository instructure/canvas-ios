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
    var items: [FileProgressViewModel] { get }
    var state: FileProgressListViewState { get }

    func cancel(env: AppEnvironment, controller: WeakViewController)
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
