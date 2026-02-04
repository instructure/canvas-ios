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
import Core
import Combine

struct HelloWidgetView: View {
    @State private var viewModel: HelloWidgetViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(viewModel: HelloWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.state == .data {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(.semibold22, lineHeight: .fit)

                Text(viewModel.message)
                    .font(.regular14, lineHeight: .fit)

            }
            .accessibilityElement(children: .combine)
            .foregroundStyle(.textDarkest)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview {
    HelloWidgetView(viewModel: .init(config: .init(id: .helloWidget, order: 0, isVisible: true)))
}
#endif
