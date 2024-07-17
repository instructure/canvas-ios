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

struct BaseScreenTesterScreen: View {
    @State var state = InstUI.ScreenState.loading

    var body: some View {
        InstUI.BaseScreen(state: state) { _ in
            VStack(spacing: 16) {
                ForEach(0..<100) { index in
                    HStack {
                        Text(verbatim: "Content")
                        Spacer()
                        Text(verbatim: "Line #\(index)")
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .overlay(alignment: .bottom) {
            Picker("", selection: $state) {
                Text(verbatim: "Loading").tag(InstUI.ScreenState.loading)
                Text(verbatim: "Error").tag(InstUI.ScreenState.error)
                Text(verbatim: "Empty").tag(InstUI.ScreenState.empty)
                Text(verbatim: "Data").tag(InstUI.ScreenState.data)
                Text(verbatim: "Data with LoadingOverlay").tag(InstUI.ScreenState.data(loadingOverlay: true))
            }
            .padding()
        }
        .navigationTitle(Text(verbatim: "Base Screen Test"))
    }
}
