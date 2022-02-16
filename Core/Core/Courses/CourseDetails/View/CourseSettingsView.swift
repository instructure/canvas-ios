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

public struct CourseSettingsView: View {

    @ObservedObject private var viewModel: CourseSettingsViewModel
    let hideColorOverlay: Bool
    let imageDownloadURL: URL?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var color: UIColor
    @State var isSaving = false
    @State var name: String
    @State var defaultView: CourseDefaultView = .wiki

    public init(viewModel: CourseSettingsViewModel) {
        self.viewModel = viewModel

        //TODO move to viewmodel
        self.hideColorOverlay = false
        imageDownloadURL = nil
        _color = State(initialValue: .red)
        _name = State(initialValue: "coursename")
    }

    public var body: some View { GeometryReader { geometry in
        let width = geometry.size.width
        EditorForm(isSpinning: isSaving) {
            let height: CGFloat = 235
            ZStack {
                Color(color).frame(width: width, height: height)
                if let url = imageDownloadURL {
                    RemoteImage(url, width: width, height: height)
                        .opacity(hideColorOverlay ? 1 : 0.4)
                }
            }
                .frame(height: height)
                .clipped()
            TextFieldRow(
                label: Text("Name", bundle: .core),
                placeholder: NSLocalizedString("Add Course Name", comment: ""),
                text: $name
            )
            Divider()
            ButtonRow(action: {
                let options = CourseDefaultView.allCases
                self.env.router.show(ItemPickerViewController.create(
                    title: NSLocalizedString("Set \"Home\" to...", comment: ""),
                    sections: [ ItemPickerSection(items: options.map {
                        ItemPickerItem(title: $0.string)
                    }), ],
                    selected: options.firstIndex(of: defaultView).flatMap {
                        IndexPath(row: $0, section: 0)
                    },
                    didSelect: { defaultView = options[$0.row] }
                ), from: controller)
            }, content: {
                Text("Set \"Home\" to...", bundle: .core)
                Spacer()
                Text("placeholder")
                    .font(.medium16).foregroundColor(.textDark)
                Spacer().frame(width: 16)
                DisclosureIndicator()
            })
                .identifier("AssignmentEditor.gradingTypeButton")
            Divider()
        }
            .navigationTitle(NSLocalizedString("Customize Course", comment: ""), subtitle: name)
            .navigationBarItems(
                leading: Button(action: cancel, label: {
                    Text("Cancel", bundle: .core).fontWeight(.regular)
                }),
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
            )
    } }

    private func save() {
    }

    func cancel() {
        controller.view.endEditing(true) // dismiss keyboard
        env.router.dismiss(controller)
    }
}

#if DEBUG
/*
struct CourseSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSettingsView()
    }
}
*/
#endif
