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
    struct Modal<Content: View>: View {
        // MARK: - Dependencies

        private let headerTitle: String
        private let headerIcon: Image?
        private let headerIconColor: Color?
        private let isShowCancelButton: Bool
        private let confirmButton: HorizonUI.ButtonAttribute?
        @Binding private var isPresented: Bool
        private let content: Content

        // MARK: - Init

        init(
            headerTitle: String,
            headerIcon: Image? = nil,
            headerIconColor: Color? = nil,
            isShowCancelButton: Bool = true,
            confirmButton: HorizonUI.ButtonAttribute? = nil,
            isPresented: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            self.headerTitle = headerTitle
            self.headerIcon = headerIcon
            self.headerIconColor = headerIconColor
            self.isShowCancelButton = isShowCancelButton
            self.confirmButton = confirmButton
            self._isPresented = isPresented
            self.content = content()
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .huiSpaces.space24) {
                headerView
                    .padding(.horizontal, .huiSpaces.space24)
                Divider()
                content
                    .padding(.horizontal, .huiSpaces.space24)
                footerView
                    .padding(.horizontal, .huiSpaces.space24)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .huiSpaces.space24)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level4)
            .padding(.horizontal, .huiSpaces.space16)
        }

        private var headerView: some View {
            HStack(alignment: .top, spacing: .huiSpaces.space24) {
                if let icon = headerIcon, let color = headerIconColor {
                    icon.frame(width: 19, height: 19)
                        .foregroundStyle(color)
                }
                Text(headerTitle)
                    .huiTypography(.h3)
                    .foregroundStyle(Color.huiColors.text.title)
                Spacer()
                HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                    isPresented.toggle()
                }
                .huiElevation(level: .level4)
            }
        }

        private var footerView: some View {
            HStack {
                Spacer()
                if isShowCancelButton {
                    HorizonUI.PrimaryButton(String(localized: "Cancel"), type: .white) {
                        isPresented.toggle()
                    }
                }

                if let confirmButton = confirmButton {
                    HorizonUI.PrimaryButton(confirmButton.title, type: .blue) {
                        confirmButton.action()
                    }
                }
            }
        }
    }
}

#Preview {
    HorizonUI.Modal(
        headerTitle: "Confirm Submission",
        confirmButton: .init(title: "Submit Attempt") {},
        isPresented: .constant(true)
    ) {
        Text(verbatim: "You are submitting a text-based attempt. Any uploaded files will be deleted upon submission. Once you submit this attempt, you won’t be able to make any changes.")
        .huiTypography(.p1)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray)
}
