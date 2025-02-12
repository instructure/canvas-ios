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
    struct Toast: View {
        // MARK: - Properties

        private let cornerRadius = CornerRadius.level3

        // MARK: - Dependencies

        private let viewModel: Toast.ViewModel
        private let onTapDismiss: (() -> Void)?

        public init(
            viewModel: Toast.ViewModel,
            onTapDismiss: (() -> Void)? = nil
        ) {
            self.viewModel = viewModel
            self.onTapDismiss = onTapDismiss
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
                if case .solid(button: let buttonAttribute) =  viewModel.buttons {
                    HorizonUI.PrimaryButton(buttonAttribute.title, type: .black) {
                        buttonAttribute.action()
                    }
                }
                if viewModel.isShowCancelButton {
                    HorizonUI.IconButton( HorizonUI.icons.close, type: .white) {
                        onTapDismiss?()
                    }
                    .padding(.trailing, .huiSpaces.primitives.mediumSmall)
                }
            }
        }

        @ViewBuilder
        private var groupButtons: some View {
            if case let .group(defaultTitleAttribute, solidTitleAttribute) =  viewModel.buttons  {
                HStack {
                    HorizonUI.PrimaryButton(defaultTitleAttribute.title, type: .white) {
                        defaultTitleAttribute.action()
                    }

                    HorizonUI.PrimaryButton(solidTitleAttribute.title, type: .black) {
                        solidTitleAttribute.action()
                    }
                }
            }
        }
    }
}

public extension HorizonUI.Toast {
    struct ButtonAttribute {
        let title: String
        let action: () -> Void

        public init(
            title: String,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.action = action
        }
    }

    struct ViewModel {
        let text: String
        let style: HorizonUI.Toast.Style
        let isShowCancelButton: Bool
        let buttons: HorizonUI.Toast.Buttons?
        public let direction: Direction
        public let dismissAfter: Double

        public init(
            text: String,
            style: HorizonUI.Toast.Style,
            isShowCancelButton: Bool = true,
            direction: Direction = .bottom,
            dismissAfter: Double = 2.0,
            buttons: HorizonUI.Toast.Buttons? = nil
        ) {
            self.text = text
            self.style = style
            self.isShowCancelButton = isShowCancelButton
            self.direction = direction
            self.dismissAfter = dismissAfter
            self.buttons = buttons
        }
    }

    enum Direction {
        case top
        case bottom

        public var alignment: Alignment {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            }
        }

        public var edge: Edge {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            }
        }
    }
}

#Preview {
    HorizonUI.Toast(viewModel: .init(text: "Alert Toast", style: .info))
    .padding(5)
}
