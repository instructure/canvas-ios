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

import HorizonUI
import SwiftUI

struct AssistTitle: View {

    // MARK: - Dependencies
    private let actionStates: [HTitleBar.Action: HTitleBar.ActionState]
    private let assistPage: HTitleBar.Page
    private let callback: HTitleBar.Callback

    // MARK: - Init
    init(
        page: HTitleBar.Page,
        actionStates: [HTitleBar.Action: HTitleBar.ActionState] = [:],
        callback: @escaping HTitleBar.Callback
    ) {
        self.assistPage = page
        self.actionStates = actionStates
        self.callback = callback
    }

    var body: some View {
        HTitleBar(
            page: assistPage,
            actionStates: actionStates,
            callback: callback
        )
        .padding(.vertical, .huiSpaces.space8)
        .overlay(
            HorizonUI.colors.surface.pageSecondary
                .frame(height: 1)
                .frame(maxWidth: .infinity),
            alignment: .bottom
        )
    }
}
