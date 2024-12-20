//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct CustomizeCourseView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @ObservedObject private var viewModel: CustomizeCourseViewModel

    init(
        viewModel: CustomizeCourseViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View { GeometryReader { geometry in
        let width = geometry.size.width

        EditorForm(isSpinning: viewModel.isLoading) {
            let height: CGFloat = 235
            ZStack {
                Color(viewModel.color)
                    .frame(width: width, height: height)
                    .animation(.default, value: viewModel.color)

                if let url = viewModel.courseImage {
                    RemoteImage(url, width: width, height: height, shouldHandleAnimatedGif: true)
                        .opacity(viewModel.hideColorOverlay ? 1 : 0.4)
                        // Fix big course image consuming tap events.
                        .contentShape(Path(CGRect(x: 0, y: 0, width: width, height: height)))
                }
            }
            .frame(height: height)
            .clipped()

            TextFieldRow(
                label: Text("Nickname", bundle: .core),
                placeholder: String(localized: "Add Course Nickname", bundle: .core),
                text: $viewModel.courseName
            )
            InstUI.Divider()
            EditorRow {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Color", bundle: .core)
                        .padding(.bottom, 8)
                    Text("This is your personal color setting. Only you will see this color for the course.", bundle: .core)
                        .font(.medium14).foregroundColor(.textDark)
                        .fixedSize(horizontal: false, vertical: true)

                    JustifiedGrid(
                        itemCount: viewModel.colors.count,
                        itemSize: CGSize(width: 48, height: 48),
                        spacing: 8,
                        width: width - 32 // account for padding coming from EditorRow
                    ) { itemIndex in
                        let item = viewModel.colors[itemIndex]
                        let uiColor = item.key
                        let isSelected = viewModel.shouldShowCheckmark(for: uiColor)
                        Button(action: { viewModel.color = uiColor }, label: {
                            Circle()
                                .fill(Color(uiColor))
                                .overlay(isSelected ? Image.checkSolid.foregroundColor(.textLightest) : nil)
                                .animation(.default, value: viewModel.color)
                        })
                        .accessibility(addTraits: isSelected ? .isSelected : [])
                        .accessibility(label: Text(item.value))
                    }
                    .padding(.vertical, 12)
                }
            }
            InstUI.Divider()
        }
        .navigationTitleStyled(navBarTitleView)
        .navigationBarItems(leading: cancelNavBarButton, trailing: doneNavBarButton)
        .navigationBarStyle(.modal)
        .onReceive(viewModel.dismissView) { _ in
            env.router.dismiss(controller)
        }
        .alert(item: $viewModel.errorMessage) { item in
            Alert(
                title: Text("Something went wrong", bundle: .core),
                message: Text(item.message),
                dismissButton: .default(Text("OK", bundle: .core))
            )
        }
    } }

    private var navBarTitleView: some View {
        VStack(spacing: 1) {
            Text("Customize Course", bundle: .core)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
            Text(viewModel.courseName)
                .font(.regular12)
                .foregroundColor(.textDark)
        }
    }

    private var cancelNavBarButton: some View {
        Button(action: cancel, label: {
            Text("Cancel", bundle: .core).fontWeight(.regular)
        })
    }

    private var doneNavBarButton: some View {
        Button(action: {
            controller.view.endEditing(true) // dismiss keyboard
            viewModel.didTapDone.send(())
        }, label: {
            Text("Done", bundle: .core).bold()
        })
        .disabled(viewModel.isLoading)
    }

    struct AlertError: Identifiable {
        let error: Error
        var id: String { error.localizedDescription }
    }

    func cancel() {
        controller.view.endEditing(true) // dismiss keyboard
        env.router.dismiss(controller)
    }
}

#if DEBUG

#Preview {
    CustomizeCourseView(
        viewModel: CustomizeCourseViewModel(
            courseId: "1",
            courseImage: nil,
            courseColor: .course1,
            courseName: "Test Course",
            hideColorOverlay: false
        )
    )
}

#endif
