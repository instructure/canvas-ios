//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct PrimaryButton<Label>: View where Label: View {

    let action: () -> Void
    let label: Label
    @State private var shouldShowAlert = false
    private let offlineService = OfflineServiceLive.shared
    private let availableOffline: Bool

    public init(availableOffline: Bool = false, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.availableOffline = availableOffline
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            if !availableOffline, offlineService.isOfflineModeEnabled() {
                shouldShowAlert = true
            } else {
                action()
            }
        } label: {
            label
        }
        .opacity(0.5)
        .alert(isPresented: $shouldShowAlert) {
            Alert(title: Text("Offline mode", bundle: .core),
                  message: Text("This item is not available offline.", bundle: .core),
                  dismissButton: .default(Text("OK", bundle: .core)))
        }
    }
}
