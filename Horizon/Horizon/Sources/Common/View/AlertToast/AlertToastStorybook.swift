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

struct AlertToastStorybook: View {
    let viewModel = AlertToastStorybookViewModel()
    var body: some View {
        VStack {
            Button {
                viewModel.showInfoToast()
            } label: {
                Text(verbatim: "Show Info Alert")
            }

            Button {
                viewModel.showErrorToast()
            } label: {
                Text(verbatim: "Show Error Alert")
            }

            Button {
                viewModel.showSuccessToast()
            } label: {
                Text(verbatim: "Show Success Alert")
            }
            Button {
                viewModel.showWarningToast()
            } label: {
                Text(verbatim: "Show Warning Alert")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alertToast(viewModel: viewModel.alertToastViewModel)
        .padding(16)
    }
}

#Preview {
    AlertToastStorybook()
}
