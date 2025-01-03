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
    struct FileDropUploader: View {

        public enum Style {
            case `default`
            case error(message: String)
            case disabled

            var isDisabled: Bool {
                switch self {
                case .disabled: return true
                default: return false
                }
            }

            var borderColor: Color {
                switch self {
                case .default, .error: return .huiColors.lineAndBorders.containerStroke
                case .disabled: return .huiColors.surface.institution
                }
            }
        }

        // MARK: - Properties

        @State private var isHover: Bool = false
        private let cornerRadius = CornerRadius.level2

        // MARK: - Dependencies

        private let style: Style
        private let onTap: () -> Void

        // MARK: - Init

        init(style: Style, onTap: @escaping () -> Void) {
            self.style = style
            self.onTap = onTap
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .huiSpaces.primitives.xSmall) {
                Button {
                    onTap()
                } label: {
                    uploadFileView
                        .frame(width: 320, height: 240)
                        .background(dashLineView)
                        .opacity(style.isDisabled ? 0.5 : 1)
                }
                .disabled(style.isDisabled)
                .onHover { isHover in
                    self.isHover = isHover
                }
                errorView
            }
        }

        private var uploadFileView: some View {
            VStack(spacing: .zero) {
                Image.huiIcons.uploadFile
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundStyle(Color.huiColors.icon.default)

                Text(verbatim: "Drag and drop a file")
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.h2)
                    .padding(.top, .huiSpaces.primitives.mediumSmall)
                    .padding(.bottom, .huiSpaces.primitives.xSmall)
                
                Text(verbatim: "Or click to upload")
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
            }
        }

        private var dashLineView: some View {
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .fill(Color.huiColors.surface.cardPrimary)
                .stroke(dashedLineColor, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
        }

        @ViewBuilder
        private var errorView: some View {
            if case .error(let errorMessage) = style {
                HStack(spacing: .huiSpaces.primitives.xxSmall) {
                    Image.huiIcons.error
                        .resizable()
                        .frame(width: 17, height: 17)
                        .foregroundStyle(Color.huiColors.icon.error)
                    Text(errorMessage)
                        .foregroundStyle(Color.huiColors.text.error)
                        .huiTypography(.labelSmall)
                }
            }
        }

        private var dashedLineColor: Color {
            isHover ? Color.huiColors.surface.institution : style.borderColor
        }
    }
}

#Preview {
    HorizonUI.FileDropUploader(style: .disabled, onTap: {})
}
