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
            .navigationBarTitleView(title: viewModel.navBar.title, subtitle: viewModel.navBar.subtitle)
            .navBarItems(leading: closeButton, trailing: doneButton)
            .navigationBarStyle(.color(viewModel.navBar.color))
            .onReceive(viewModel.dismissView) {
                viewcontroller.value.dismiss(animated: true)
            }
            .alert(item: $viewModel.error) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
    }

    private var closeButton: some View {
        Button(action: viewModel.closeTapped, label: {
            Text(viewModel.navBar.closeButtonTitle)
                .foregroundColor(.textLightest.variantForLightMode)
        })
    }

    private var doneButton: some View {
        Button(action: viewModel.postSubmission, label: {
            // TODO: SwiftUIWorkaround
            // If we use Text alone here then its font weight will be overridden by the nav bar but
            // if we wrap it in a stack and add an image next to it we can customize the appearance.
            HStack {
                Image.assignmentLine.frame(width: 0, height: 0).clipped() // We don't want this image to be visible
                Text(viewModel.doneButton.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.textLightest.variantForLightMode)
                    .opacity(viewModel.doneButton.opacity)
            }
        }).disabled(viewModel.doneButton.isDisabled)
    }
}
