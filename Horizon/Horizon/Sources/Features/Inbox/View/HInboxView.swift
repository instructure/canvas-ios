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
import Core

struct HInboxView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController
    let notAvailableYetFeatureView: NotAvailableYetFeatureView

    var body: some View {
        notAvailableYetFeatureView
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.all, .huiSpaces.space24)
            .safeAreaInset(edge: .top, spacing: .zero) {
                navigationBar
            }
            .background(Color.huiColors.surface.pagePrimary)
    }

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in
                dismiss()
            }
        ) {
            Text("Inbox").huiTypography(.h3)
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space16)
    }
}

#Preview {
    HInboxView(
        notAvailableYetFeatureView: NotAvailableYetFeatureView(
            viewModel: NotAvailableYetFeatureViewModel(
                feature: .inbox,
                router: AppEnvironment.shared.router,
                baseURL: URL(string: "https://www.instructure.com")!
            )
        )
    )
}
