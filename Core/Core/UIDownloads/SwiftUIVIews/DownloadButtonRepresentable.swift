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

struct DownloadButtonRepresentable: UIViewRepresentable {

    @Binding public var progress: Float
    @Binding public var currentState: DownloadButton.State

    public var mainTintColor: UIColor = .blue
    public var onState: ((DownloadButton.State) -> Void)?
    public var onTap: ((DownloadButton.State) -> Void)?

    init(
        progress: Binding<Float>,
        currentState: Binding<DownloadButton.State>,
        mainTintColor: UIColor = .blue,
        onState: ((DownloadButton.State) -> Void)?,
        onTap: ((DownloadButton.State) -> Void)?
    ) {
        self._progress = progress
        self._currentState = currentState
        self.mainTintColor = mainTintColor
        self.onState = onState
        self.onTap = onTap
    }

    public func makeUIView(context: Self.Context) -> DownloadButton {
        DownloadButton(frame: .zero)
    }

    public func updateUIView(_ uiView: DownloadButton, context: Self.Context) {
        uiView.progress = progress
        uiView.mainTintColor = mainTintColor
        uiView.currentState = currentState
        uiView.onState = onState
        uiView.onTap = onTap

        if currentState == .waiting {
            uiView.waitingView.startSpinning()
        }
    }
}
