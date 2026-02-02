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
    @State var viewModel: HelloWidgetViewModel

    init(viewModel: HelloWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .error, .loading: SwiftUI.EmptyView()
        case .success(let greeting, let message): content(greeting: greeting, message: message)
        }
    }

    @ViewBuilder
    private func content(
        greeting: String.LocalizationValue,
        message: String.LocalizationValue
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(.init(greeting, bundle: .student))
                .font(.semibold22)
                .fontWeight(.semibold)

            Text(.init(message, bundle: .student))
                .font(.regular14)
        }
        .foregroundStyle(.textDarkest)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HelloWidgetView(viewModel: .init(refresh: PassthroughSubject<Void, Never>()))
}
