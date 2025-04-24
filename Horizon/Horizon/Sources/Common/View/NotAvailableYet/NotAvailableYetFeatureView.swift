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

struct NotAvailableYetFeatureView: View {

    @Environment(\.viewController) private var viewController

    let viewModel: NotAvailableYetFeatureViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text(viewModel.description)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .padding(.bottom, .huiSpaces.space8)
            HStack {
                Text("Log In", bundle: .horizon)
                    .underline()
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.buttonTextLarge)
                HorizonUI.icons.openInNew
                    .foregroundStyle(Color.huiColors.text.body)
            }.onTapGesture {
                viewModel.openCanvasForCareerSkillspaceOnWeb(viewController: viewController)
            }
        }
    }
}

#Preview {
    NotAvailableYetFeatureView(
        viewModel: NotAvailableYetFeatureViewModel(
            feature: .inbox,
            router: AppEnvironment.shared.router,
            baseURL: URL(string: "https://www.instructure.com")!
        )
    )
}
