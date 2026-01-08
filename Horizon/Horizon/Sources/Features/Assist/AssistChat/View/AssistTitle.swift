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
    private var backOpacity: Double {
        onBack == nil ? 0 : 1
    }
    private let onBack: OnBack?
    private let onClose: OnClose

    // MARK: - Init
    init(onBack: OnBack? = nil, onClose: @escaping OnClose) {
        self.onBack = onBack
        self.onClose = onClose
    }

    var body: some View {
        HStack(spacing: .huiSpaces.space8) {
            title
            Spacer()
            back
            close
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
    private var back: some View {
        HorizonUI.IconButton(
            Image.huiIcons.arrowBack,
            type: .whiteOutline,
            isSmall: true,
            action: onBack ?? { }
        )
        .opacity(backOpacity)
        .animation(.easeInOut(duration: 0.2), value: backOpacity)
        .accessibilityLabel(String(localized: "Back"))
    }

    private var close: some View {
        HorizonUI.IconButton(
            Image.huiIcons.close,
            type: .whiteOutline,
            isSmall: true,
            action: onClose
        )
    }

    private var title: some View {
        HStack {
            HorizonUI.icons.aiFilled
                .accessibilityHidden(true)
            Text(String(localized: "IgniteAI", bundle: .horizon))
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
