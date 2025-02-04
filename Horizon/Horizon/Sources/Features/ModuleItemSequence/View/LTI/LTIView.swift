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
import HorizonUI
import Core

struct LTIView: View {

    @Environment(\.viewController) private var controller
    private var viewModel: LTIViewModel

    init(viewModel: LTIViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            launchButton()
                .padding(.top, .huiSpaces.primitives.medium)
            WebView(url: viewModel.urlToDisplay)
                .padding(.all, .huiSpaces.primitives.medium)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func launchButton() -> some View {
        HorizonUI.TextButton(
            String(localized: "Open in a New Tab", bundle: .horizon),
            trailing: .huiIcons.openInNew
        ) {
            viewModel.launchUrl(weakViewController: controller)
        }
    }
}

#Preview {
    LTIView(viewModel: LTIViewModel(
        tools: LTITools(
            url: URL(string: "https://www.instructure.com")!,
            isQuizLTI: false
        )
    ))
}
