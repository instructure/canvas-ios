//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct OfflineObservingButton<Label>: View where Label: View {

    @StateObject private var viewModel = OfflineModeAssembly.makeViewModel()

    private let action: () -> Void
    private let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            if viewModel.isOffline {
                UIAlertController.showItemNotAvailableInOfflineAlert()
            } else {
                action()
            }
        } label: {
            label
        }
        .opacity(viewModel.isOffline ? UIButton.DisabledInOfflineAlpha : 1.0)
    }
}
