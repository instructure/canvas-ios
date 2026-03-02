//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import HorizonUI
import SwiftUI

struct EnrollConfirmationView: View {
    @Environment(\.viewController) private var viewController
    @State var viewModel: EnrollConfirmationViewModel
    var body: some View {
        contentView
    }

    private var contentView: some View {
        VStack(spacing: .zero) {
            headerView
            if let overView = viewModel.overView {
               ScrollView {
                    WebView(html: overView, isScrollEnabled: false)
                        .frameToFit()
                }
            } else {
                Text("Enroll to access the course and start learning")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .padding(.horizontal, .huiSpaces.space16)
                    .padding(.vertical, .huiSpaces.space24)
            }
            Spacer()
            footer
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level4)
        .huiLoader(isVisible: viewModel.isLoaderVisible)
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack {
                Text("Ready to join?")
                    .huiTypography(.h3)
                    .foregroundStyle(Color.huiColors.text.title)
                Spacer()
                HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                    viewModel.dismiss(viewController: viewController)
                }
                .padding(.trailing, .huiSpaces.space8)
                .disabled(viewModel.isEnrollLoaderVisible)
            }
            .padding(.leading, .huiSpaces.space16)
            .padding(.top, .huiSpaces.space24)
            lineView
        }
    }

    private var footer: some View {
       VStack {
           lineView
            HStack {
                HorizonUI.PrimaryButton(
                    String(localized: "Not now"),
                    type: .white,
                    fillsWidth: false
                ) {
                    viewModel.dismiss(viewController: viewController)
                }
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)
                .disabled(viewModel.isEnrollLoaderVisible)

                Spacer()
                HorizonUI.LoadingButton(
                        title: String(localized: "Enroll"),
                        type: .black,
                        fillsWidth: false,
                        isLoading: viewModel.isEnrollLoaderVisible
                    ) {
                        viewModel.enroll(viewController: viewController)
                }
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)
            }
        }
    }

    private var lineView: some View {
        Rectangle()
            .fill(Color.huiColors.lineAndBorders.lineDivider)
            .frame(height: 1)
    }
}
