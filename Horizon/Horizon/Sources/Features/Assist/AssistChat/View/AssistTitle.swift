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

struct AssistTitle: View {
    typealias OnBack = () -> Void
    typealias OnClose = () -> Void

    // MARK: - Private Properties
    private var isBackButtonVisible: Bool { onBack != nil }
    private let onBack: OnBack?
    private let onTapInfo: OnBack?
    private let onClose: OnClose

    // MARK: - Init

    init(
        onBack: OnBack? = nil,
        onClose: @escaping OnClose,
        onTapInfo: OnBack? = nil
    ) {
        self.onBack = onBack
        self.onClose = onClose
        self.onTapInfo = onTapInfo
    }

    var body: some View {
        HStack(spacing: .huiSpaces.space8) {
            if isBackButtonVisible { backButton }
            title
            Spacer()
            Button {
                onTapInfo?()
            } label: {
                Image.huiIcons.info
                    .padding(.huiSpaces.space4)
                    .foregroundStyle(Color.huiColors.icon.surfaceColored)
            }
            closeButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space16)
        .overlay(
            HorizonUI.colors.surface.pageSecondary
                .frame(height: 1)
                .frame(maxWidth: .infinity),
            alignment: .bottom
        )
    }

    // MARK: - Private
    private var backButton: some View {
        HorizonUI.IconButton(
            Image.huiIcons.arrowBack,
            type: .whiteOutline,
            isSmall: true,
            action: onBack ?? { }
        )
        .accessibilityLabel(String(localized: "Back"))
    }

    private var closeButton: some View {
        Button {
            onClose()
        } label: {
            Image.huiIcons.close
                .padding(.huiSpaces.space4)
                .foregroundStyle(Color.huiColors.icon.surfaceColored)
        }
    }

    private var title: some View {
        HStack {
            HorizonUI.icons.aiFilled
                .accessibilityHidden(true)
            Text(String(localized: "Study Tools", bundle: .horizon))
                .huiTypography(.h4)
                .accessibilityAddTraits(.isHeader)
        }
        .foregroundStyle(Color.textLightest)
        .foregroundStyle(Color.huiColors.text.surfaceColored)
    }

}

#Preview {
    VStack(alignment: .leading) {
        AssistTitle(onClose: { })
    }
    .frame(maxHeight: .infinity)
    .padding(.horizontal, .huiSpaces.space16)
    .background(Color.gray)
}
