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

public extension HorizonUI.Toast {
    struct Storybook: View {
        let viewModel = StorybookViewModel()
        @State var isPresented: Bool = false

        public  var body: some View {
            VStack {
                Button {
                    viewModel.showInfoToast()
                    isPresented = true
                } label: {
                    Text(verbatim: "Show Info Alert")
                }

                Button {
                    viewModel.showErrorToast()
                    isPresented = true
                } label: {
                    Text(verbatim: "Show Error Alert")
                }

                Button {
                    viewModel.showSuccessToast()
                    isPresented = true
                } label: {
                    Text(verbatim: "Show Success Alert")
                }
                Button {
                    viewModel.showWarningToast()
                    isPresented = true
                } label: {
                    Text(verbatim: "Show Warning Alert")
                }

                Button {
                    isPresented = false
                } label: {
                    Text(verbatim: "Dismiss")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .huiToast(viewModel: viewModel.toastViewModel, isPresented: $isPresented)
            .padding(16)
            .navigationTitle("Alert Toast")
        }
    }
}

#Preview {
    HorizonUI.Toast.Storybook()
}
