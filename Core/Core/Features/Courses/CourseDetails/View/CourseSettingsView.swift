//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct CourseSettingsView: View, ScreenViewTrackable {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: CourseSettingsViewModel
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    public init(viewModel: CourseSettingsViewModel) {
        self.viewModel = viewModel
        self.screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)/settings"
        )

    }

    public var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .ready, .saving:
                editor(width: geometry.size.width)
            }
        }
        .navigationBarTitleView(
            title: String(localized: "Customize Course", bundle: .core),
            subtitle: viewModel.courseName
        )
        .navBarItems(
            leading: {
                Button(action: cancelTapped) {
                    Text("Cancel", bundle: .core).fontWeight(.regular)
                }
            },
            trailing: {
                Button(action: doneTapped) {
                    Text("Done", bundle: .core).bold()
                }
                .disabled(viewModel.state != .ready)
            }
        )
        .navigationBarStyle(.modal)
        .onAppear(perform: viewModel.viewDidAppear)
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text(viewModel.errorText ?? String(localized: "Something went wrong", bundle: .core)))
        }
    }

    private func editor(width: CGFloat) -> some View {
        EditorForm(isSpinning: viewModel.state == .saving) {
            let height: CGFloat = 235
            ZStack {
                Color(viewModel.courseColor ?? .textDark).frame(width: width, height: height)
                if let url = viewModel.imageURL {
                    RemoteImage(url, width: width, height: height, shouldHandleAnimatedGif: true)
                        .opacity(viewModel.hideColorOverlay == true ? 1 : 0.4)
                        .accessibility(hidden: true)
                }
            }
                .frame(height: height)
                .clipped()
            nameRow
            Divider()
            defaultViewButtonRow
            Divider()
        }
    }

    private var nameRow: some View {
        TextFieldRow(
            label: Text("Name", bundle: .core),
            placeholder: String(localized: "Add Course Name", bundle: .core),
            text: $viewModel.newName
        )
    }

    private var defaultViewButtonRow: some View {
        ButtonRow(action: {
            viewModel.defaultViewSelectorTapped(router: env.router, viewController: controller)
        }) {
            Text("Set \"Home\" to...", bundle: .core)
            Spacer()
            Text(viewModel.newDefaultView.string)
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        }
    }

    private func doneTapped() {
        controller.view.endEditing(true) // dismiss keyboard
        viewModel.doneTapped(router: env.router, viewController: controller)
    }

    func cancelTapped() {
        controller.view.endEditing(true) // dismiss keyboard
        env.router.dismiss(controller)
    }
}

struct CourseSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSettingsView(viewModel: CourseSettingsViewModel(context: .course("1")))
    }
}
