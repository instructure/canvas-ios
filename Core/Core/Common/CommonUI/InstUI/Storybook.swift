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

extension InstUI {
    public struct Storybook: View {
        public init() {}

        public var body: some View {
            List {
                Section(header: Text(verbatim: "Components")) {
                    NavigationLink {
                        InstUI.PageIndicator.Storybook()
                    } label: {
                        Text(verbatim: "Page Indicator")
                            .tint(Color.textDarkest)
                    }

                    NavigationLink {
                        PillButtonStorybook()
                    } label: {
                        Text(verbatim: "Pill Button")
                            .tint(Color.textDarkest)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationBarHidden(false)
            .navigationTitle(Text(verbatim: "InstUI Design System"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        InstUI.Storybook()
    }
}
#endif
