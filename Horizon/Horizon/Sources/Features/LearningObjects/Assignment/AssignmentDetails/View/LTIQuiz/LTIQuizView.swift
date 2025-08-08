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
import HorizonUI
import Core

struct LTIQuizView: View {
    let viewModel: LTIQuizViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            headerView
            WebView(
                url: viewModel.externalURL,
                features: [
                    .invertColorsInDarkMode,
                    .hideReturnButtonInQuizLTI,
                    .onSubmitQuiz {
                        viewModel.refershCourse()
                    },
                    .onAppearElement(Id: "Spinner___0") {
                        viewModel.isLoaderVisible = false
                    }
                ]
            )
        }
        .overlay(alignment: .topTrailing) {
            HStack {
                if viewModel.isButtonLoaderVisible {
                    HorizonUI.Spinner(size: .xSmall, showBackground: false)
                } else {
                    HorizonUI.IconButton(Image.huiIcons.close, type: .white, isSmall: true) {
                        dismiss()
                    }
                    .huiElevation(level: .level4)
                }
            }
            .padding(.huiSpaces.space24)
        }
        .overlay { loaderView }
        .background(Color.huiColors.surface.pageSecondary)
    }
    private var headerView: some View {
        Text(viewModel.name)
            .foregroundStyle(Color.huiColors.text.title)
            .frame(maxWidth: .infinity)
            .huiTypography(.h3)
            .padding(.top, .huiSpaces.space32)
            .padding(.horizontal, .huiSpaces.space48)
            .padding(.horizontal, .huiSpaces.space10)
    }
    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
    }
}
