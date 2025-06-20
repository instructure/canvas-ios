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

struct ProfileView: View {

    @Bindable
    private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ProfileBody(String(localized: "Profile", bundle: .horizon)) {
            ScrollView {
                VStack(spacing: .huiSpaces.space24) {
                    nameView
                    displayNameView
                    emailView
                    saveButton
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.huiColors.surface.pageSecondary)
                .padding(.horizontal, .huiSpaces.space24)
                .padding(.vertical, .huiSpaces.space48)
            }
            .alert(isPresented: $viewModel.isAlertErrorPresented) {
                Alert(title: Text(viewModel.errorMessage), message: Text(viewModel.errorMessage))
            }
        }
        .overlay { loaderView }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }
    private var nameView: some View {
        HorizonUI.TextInput(
            $viewModel.name,
            label: String(localized: "Full Name", bundle: .horizon),
            error: viewModel.nameError,
            helperText: !viewModel.canUpdateName
            ? String(localized: "Full Name can only be changed by your institution.", bundle: .horizon)
            : nil,
            disabled: viewModel.nameDisabled
        )
    }

    private var displayNameView: some View {
        HorizonUI.TextInput(
            $viewModel.displayName,
            label: String(localized: "Display Name", bundle: .horizon),
            error: viewModel.displayNameError,
            helperText: !viewModel.canUpdateName
            ? String(localized: "Display Name can only be changed by your institution.", bundle: .horizon)
            : nil,
            disabled: viewModel.displayNameDisabled
        )
    }

    private var emailView: some View {
        HorizonUI.TextInput(
            $viewModel.email,
            label: String(localized: "Email", bundle: .horizon),
            helperText: String(localized: "Email can only be changed by your institution", bundle: .horizon),
            disabled: true
        )
    }

    private var saveButton: some View {
        SavingButton(
            title: String(localized: "Save Changes", bundle: .horizon),
            isLoading: $viewModel.saveLoaderIsVisiable,
            isDisabled: $viewModel.isSaveDisabled,
            onSave: viewModel.save
        )
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel()
    )
}
