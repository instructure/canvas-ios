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
        
        private let cornerRadius = CornerRadius.level2
        
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
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                    .fill(Color.huiColors.surface.pageSecondary)
                    .stroke(viewModel.style.color, lineWidth: HorizonUI.Borders.level2.rawValue)
                
                contentView
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, .huiSpaces.space24)
        }
        
        private var contentView: some View {
            HStack(alignment: .top, spacing: .zero) {
                alertIcon
                VStack(alignment: .leading, spacing: .zero) {
                    textView
                        .padding(.huiSpaces.space16)
                    groupButtons
                        .padding(.bottom, .huiSpaces.space16)
                }
                trailingButtons
                    .padding(.top,.huiSpaces.space16)
            }
            .frame(minHeight: 64)
        }
        
        private var alertIcon: some View {
            Rectangle()
                .fill(viewModel.style.color)
                .frame(width: 50)
                .huiCornerRadius(level: cornerRadius, corners: [.topLeft, .bottomLeft])
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
            HStack(alignment: .top, spacing: .huiSpaces.space16) {
                if case .single(confirmButton: let confirmButton) =  viewModel.buttons {
                    HorizonUI.PrimaryButton(confirmButton.title, type: .black) {
                        confirmButton.action()
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                if viewModel.isShowCancelButton {
                    Button {
                        onTapDismiss?()
                    } label: {
                        HorizonUI.icons.close
                            .foregroundStyle(Color.huiColors.icon.default)
                    }
                    .padding(.trailing, .huiSpaces.space16)
                }
            }
        }
        
        @ViewBuilder
        private var groupButtons: some View {
            if case let .double(cancelButton: cancelButton, confirmButton: confirmButton) =  viewModel.buttons  {
                HStack(alignment: .top) {
                    HorizonUI.PrimaryButton(cancelButton.title, type: .white) {
                        cancelButton.action()
                    }
                    
                    HorizonUI.PrimaryButton(confirmButton.title, type: .black) {
                        confirmButton.action()
                    }
                }
            }
        }
    }
}

public extension HorizonUI.Toast {
    struct ViewModel {
        let text: String
        let style: HorizonUI.Toast.Style
        let isShowCancelButton: Bool
        let buttons: HorizonUI.Toast.Buttons?
        let direction: Direction
        let dismissAfter: Double?
        public init(
            text: String,
            style: HorizonUI.Toast.Style,
            isShowCancelButton: Bool = true,
            direction: Direction = .top,
            dismissAfter: Double? = 3.0,
            confirmActionButton: HorizonUI.ButtonAttribute? = nil,
            cancelActionButton: HorizonUI.ButtonAttribute? = nil
        ) {
            self.text = text
            self.style = style
            self.isShowCancelButton = isShowCancelButton
            self.direction = direction
            self.dismissAfter = dismissAfter
            if let confirmActionButton, let cancelActionButton {
                buttons = .double(cancelButton: cancelActionButton, confirmButton: confirmActionButton)
            } else if let confirmActionButton {
                buttons = .single(confirmButton: confirmActionButton)
            } else {
                self.buttons = nil
            }
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

public extension HorizonUI {
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
}
#Preview {
    ZStack {
        Color.black
        HorizonUI.Toast(viewModel: .init(text: "Alert Toast", style: .info))
    }
}
