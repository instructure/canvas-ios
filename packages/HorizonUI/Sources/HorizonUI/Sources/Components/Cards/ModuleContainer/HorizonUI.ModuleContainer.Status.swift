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

import SwiftUI

public extension HorizonUI.ModuleContainer {
    enum Status {
        case optional
        case notStarted
        case inProgress
        case completed
        case locked

       public var title: String {
            switch self {
            case .optional: ""
            case .notStarted: String(localized: "Not started")
            case .inProgress: String(localized: "In progress")
            case .completed: String(localized: "Completed")
            case .locked: String(localized: "Locked")
            }
        }

        var imageHeight: CGFloat {
            switch self {
            case .optional: return 24
            case .notStarted, .locked: return 20
            default: return 33
            }
        }
    }
}

extension HorizonUI.ModuleContainer {
    struct StatusView: View {
        let status: Status

        var body: some View {
            switch status {
            case .optional: EmptyView()
            case .notStarted: notStartedView
            case .inProgress: inProgressView
            case .completed: completedView
            case .locked: lockedView
            }
        }

        private var notStartedView: some View {
            HorizonUI.StatusChip(
                title: status.title,
                style: .institution,
                isFilled: false
            )
        }

        private var inProgressView: some View {
            HorizonUI.StatusChip(
                title: status.title,
                style: .institution,
                isFilled: false
            )
        }

        private var completedView: some View {
            HorizonUI.StatusChip(
                title: status.title,
                style: .institution,
            )
        }

        private var lockedView: some View {
            HorizonUI.StatusChip(
                title: status.title,
                style: .institution,
                icon: Image.huiIcons.lock,
                isFilled: false
            )
        }
    }
}

#Preview {
    HorizonUI.ModuleContainer.StatusView(status: .completed)
}
