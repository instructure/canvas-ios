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

public extension HorizonUI {
    struct AlertToast: View {
        // MARK: - Properties

        private let cornerRadius = CornerRadius.level3

        // MARK: - Dependencies

        private let viewModel: AlertToast.ViewModel
        private let onTapCancel: (() -> Void)?

        public init(
            viewModel: AlertToast.ViewModel,
            onTapCancel: (() -> Void)? = nil
        ) {
            self.viewModel = viewModel
            self.onTapCancel = onTapCancel
        }

        public var body: some View {
            HStack(alignment: .top, spacing: .zero) {
                alertIcon
                VStack(alignment: .leading, spacing: .zero) {
                    textView
                        .padding(.huiSpaces.primitives.mediumSmall)
                    groupButtons
                        .padding(.bottom, .huiSpaces.primitives.mediumSmall)
                }
                trailingButtons
                    .padding(.top,.huiSpaces.primitives.mediumSmall)
            }
            .frame(minHeight: 64)
            .huiBorder(level: .level2, color: viewModel.style.color, radius: cornerRadius.attributes.radius)
            .huiCornerRadius(level: cornerRadius)
            .fixedSize(horizontal: false, vertical: true)
        }

        private var alertIcon: some View {
            Rectangle()
                .fill(viewModel.style.color)
                .frame(width: 50)
                .overlay {
                    viewModel.style.image
                        .foregroundStyle(Color.huiColors.icon.surfaceColored)
                }
        }

        private var textView: some View {
            Text(viewModel.text)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.p1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        private var trailingButtons: some View {
            HStack(spacing: .huiSpaces.primitives.mediumSmall) {
                if case .solid(title: let title) =  viewModel.buttons {
                    HorizonUI.PrimaryButton(title, type: .black) {
                        viewModel.onTapSolidButton?()
                    }
                }
                if viewModel.isShowCancelButton {
                    HorizonUI.IconButton( HorizonUI.icons.close, type: .white) {
                        onTapCancel?()
                    }
                    .padding(.trailing, .huiSpaces.primitives.mediumSmall)
                }
            }
        }

        @ViewBuilder
        private var groupButtons: some View {
            if case let .group(defaultTitle, solidTitle) =  viewModel.buttons  {
                HStack {
                    HorizonUI.PrimaryButton(defaultTitle, type: .white) {
                        viewModel.onTapDefaultButton?()
                    }

                    HorizonUI.PrimaryButton(solidTitle, type: .black) {
                        viewModel.onTapSolidButton?()
                    }
                }
            }
        }
    }
}

#Preview {
    HorizonUI.AlertToast(viewModel: .init(text: "Alert Toast", style: .info))
    .padding(5)
}

