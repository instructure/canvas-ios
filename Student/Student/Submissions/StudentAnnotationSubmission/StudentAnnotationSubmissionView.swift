//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import SwiftUI

public struct StudentAnnotationSubmissionView: View {
    @Environment(\.viewController) private var viewcontroller
    @ObservedObject private var viewModel: StudentAnnotationSubmissionViewModel

    public init(viewModel: StudentAnnotationSubmissionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        DocViewer(filename: "", previewURL: viewModel.documentURL, fallbackURL: viewModel.documentURL)
            .navBarItems(leading: closeButton, trailing: doneButton)
            .navigationTitles(
                title: viewModel.navBar.title,
                subtitle: viewModel.navBar.subtitle,
                style: .color(viewModel.navBar.color)
            )
            .onReceive(viewModel.dismissView) {
                viewcontroller.value.dismiss(animated: true)
            }
            .alert(item: $viewModel.error) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
            .tint(viewModel.navBar.color.asColor)
    }

    private var closeButton: some View {
        Button(action: viewModel.closeTapped) {
            Text(viewModel.navBar.closeButtonTitle)
                .toolbarItemForegroundStyle(.textLightest.variantForLightMode)
        }
    }

    private var doneButton: some View {
        Button(action: viewModel.postSubmission) {
            Text(viewModel.doneButton.title)
                .fontWeight(.semibold)
                .toolbarItemForegroundStyle(.textLightest.variantForLightMode)
                .opacity(viewModel.doneButton.opacity)

        }
        .disabled(viewModel.doneButton.isDisabled)
    }
}
