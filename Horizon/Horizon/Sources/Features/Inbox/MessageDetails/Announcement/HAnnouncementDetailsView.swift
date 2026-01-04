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

import Core
import HorizonUI
import SwiftUI

struct HAnnouncementDetailsView: View {
    @State var viewModel: HAnnouncementDetailsViewModel
    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss

    init(viewModel: HAnnouncementDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        messages
            .background(HorizonUI.colors.surface.pagePrimary)
            .safeAreaInset(edge: .top) { titleBar }
            .navigationBarHidden(true)
    }

    private var messages: some View {
        announcementView(viewModel.notificationModel.announcementContent ?? "")
            .padding([.leading, .trailing, .bottom], HorizonUI.spaces.space24)
            .padding(.top, HorizonUI.spaces.space16)
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity)
            .background(HorizonUI.colors.surface.pageSecondary)
            .roundedTopCorners()
    }

    private func announcementView(_ message: String) -> some View {
        WebView(html: message, isScrollEnabled: false)
            .frameToFit()
            .padding(.horizontal, -16)
    }

    private var titleBar: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                HorizonUI.icons.announcement
                    .renderingMode(.template)
                    .foregroundStyle(HorizonUI.colors.surface.institution)
                    .accessibilityHidden(true)
                Text(viewModel.notificationModel.title)
                    .lineLimit(2)
                    .huiTypography(.labelLargeBold)
                    .foregroundColor(HorizonUI.colors.surface.institution)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            backButton
        }
        .padding(.horizontal, HorizonUI.spaces.space24)
    }

    private var backButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.arrowBack,
            type: .ghost
        ) {
            dismiss()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Back"))
        .accessibilityAddTraits(.isButton)
    }
}
