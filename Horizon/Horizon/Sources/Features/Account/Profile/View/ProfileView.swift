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
import Observation
import SwiftUI

struct ProfileView: View {

    @Bindable
    private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            AccountNavigationBar(String(localized: "Profile", bundle: .horizon))
                .background(Color.huiColors.surface.pagePrimary)

            ScrollView {
                VStack(spacing: .huiSpaces.primitives.medium) {
                    nameView
                    displayNameView
                    emailView
                    saveButton
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.huiColors.surface.pageSecondary)
                .padding(.horizontal, .huiSpaces.primitives.medium)
                .padding(.vertical, .huiSpaces.primitives.xLarge)
            }
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar(.hidden)
        .background(Color.huiColors.surface.pagePrimary)
    }

    @ViewBuilder
    var nameView: some View {
        HorizonUI.TextInput(
            $viewModel.name,
            label: String(localized: "Full Name", bundle: .horizon),
            error: viewModel.nameError,
            disabled: viewModel.nameDisabled
        )
    }

    @ViewBuilder
    var displayNameView: some View {
        HorizonUI.TextInput(
            $viewModel.displayName,
            label: String(localized: "Display Name", bundle: .horizon),
            error: viewModel.displayNameError,
            helperText: String(localized: "Required", bundle: .horizon),
            disabled: viewModel.displayNameDisabled
        )
    }

    @ViewBuilder
    var emailView: some View {
        HorizonUI.TextInput(
            $viewModel.email,
            label: String(localized: "Email", bundle: .horizon),
            helperText: String(localized: "Email can only be changed by your institution", bundle: .horizon),
            disabled: true
        )
    }

    @ViewBuilder
    var saveButton: some View {
        ZStack {
            HorizonUI.PrimaryButton(
                String(localized: "Save Changes", bundle: .horizon),
                type: .black,
                fillsWidth: true
            ) {
                viewModel.save()
            }
            .opacity(viewModel.isLoading ? 0.25 : 1.0)
            .animation(.easeInOut, value: viewModel.isLoading)
            .disabled(viewModel.isSaveDisabled)

            HorizonUI.Spinner(size: .xSmall)
                .opacity(viewModel.isLoading ? 1.0 : 0.0)
                .animation(.easeInOut, value: viewModel.isLoading)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel()
    )
}
