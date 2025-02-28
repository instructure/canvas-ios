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

public struct PageEditorView: View {
    let context: Context
    let url: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var title: String = ""
    @State var html: String = ""
    @State var editingRoles: RoleOption = .members
    @State var published: Bool = false
    @State var isFrontPage: Bool = false

    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var showError: Bool = false
    @State var error: Error? {
        didSet { showError = error != nil }
    }

    public init(context: Context, url: String? = nil) {
        self.context = context
        self.url = url
    }

    public var body: some View {
        form
            .navigationBarTitleView(url == nil
                                        ? String(localized: "New Page", bundle: .core)
                                        : String(localized: "Edit Page", bundle: .core)
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core)
                })
                    .identifier("screen.dismiss"),
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                    .disabled(isLoading || isSaving)
                    .identifier("PageEditor.doneButton")
            )
            .navigationBarStyle(.modal)

            .alert(isPresented: $showError) {
                Alert(title: Text(error!.localizedDescription))
            }

            .onAppear(perform: load)
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            if env.app == .teacher || context.contextType == .group {
                EditorSection(label: Text("Title", bundle: .core)) {
                    CustomTextField(placeholder: Text("Add Title", bundle: .core),
                                    text: $title,
                                    identifier: "PageEditor.titleField",
                                    accessibilityLabel: Text("Title", bundle: .core))
                }
            } else {
                Text(title)
                    .font(.bold20).foregroundColor(.textDarkest)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .identifier("PageEditor.titleText")
            }

            EditorSection(label: Text("Content", bundle: .core)) {
                RichContentEditor(
                    env: env,
                    placeholder: String(localized: "Add content", bundle: .core),
                    a11yLabel: String(localized: "Page content", bundle: .core),
                    html: $html,
                    uploadParameters: .init(context: context),
                    height: $rceHeight,
                    canSubmit: $rceCanSubmit,
                    error: $error
                )
                    .frame(height: max(200, rceHeight))
            }

            if env.app == .teacher || context.contextType == .group {
                EditorSection(label: Text("Details", bundle: .core)) {
                    if url != "front_page" && env.app == .teacher {
                        InstUI.Toggle(isOn: $published) { Text("Publish", bundle: .core) }
                            .font(.semibold16).foregroundColor(.textDarkest)
                            .padding(16)
                            .disabled(isFrontPage)
                            .identifier("PageEditor.publishedToggle")
                        Divider()
                    }
                    if url != "front_page" && env.app == .teacher {
                        InstUI.Toggle(isOn: $isFrontPage) { Text("Set as Front Page", bundle: .core) }
                            .font(.semibold16).foregroundColor(.textDarkest)
                            .padding(16)
                            .disabled(!published)
                            .identifier("PageEditor.frontPageToggle")
                        Divider()
                    }
                    ButtonRow(action: {
                        let options: [RoleOption] = context.contextType == .group
                            ? [ .members, .public ]
                            : [ .teachers, .teachersAndStudents, .public ]
                        self.env.router.show(ItemPickerViewController.create(
                            title: String(localized: "Can Edit", bundle: .core),
                            sections: [ ItemPickerSection(items: options.map {
                                ItemPickerItem(title: $0.string)
                            }) ],
                            selected: options.firstIndex(of: editingRoles).flatMap {
                                IndexPath(row: $0, section: 0)
                            },
                            didSelect: { editingRoles = options[$0.row] }
                        ), from: controller)
                    }, content: {
                        Text("Can Edit", bundle: .core)
                        Spacer()
                        Text(editingRoles.string)
                            .font(.medium16).foregroundColor(.textDark)
                        Spacer().frame(width: 16)
                        DisclosureIndicator()
                    })
                        .identifier("PageEditor.editorsButton")
                }
            }
        }
    }

    func load() {
        guard !isLoaded else { return }
        guard let url = url else {
            editingRoles = context.contextType == .group ? .members : .teachers
            isLoading = false
            isLoaded = true
            return
        }
        let useCase = GetPage(context: context, url: url)
        useCase.fetch { _, _, error in performUIUpdate {
            let page: Page? = self.env.database.viewContext.fetch(scope: useCase.scope).first
            var editingRoles = RoleOption.public
            if page?.editingRoles.contains("teachers") == true { editingRoles = .teachers }
            if page?.editingRoles.contains("students") == true { editingRoles = .teachersAndStudents }
            if page?.editingRoles.contains("members") == true { editingRoles = .members }
            self.title = page?.title ?? ""
            self.html = page?.body ?? ""
            self.editingRoles = editingRoles
            self.published = page?.published ?? false
            self.isFrontPage = page?.isFrontPage ?? false
            self.isLoading = false
            self.isLoaded = true
            self.error = error
        } }
    }

    func save() {
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        UpdatePage(
            context: context,
            url: url,
            title: title,
            body: html,
            editing_roles: editingRoles.rawValue,
            published: published || isFrontPage,
            front_page: isFrontPage
        ).fetch { result, _, error in performUIUpdate {
            self.error = error
            self.isSaving = false
            if result != nil {
                env.router.dismiss(controller)
            }
        } }
    }

    enum RoleOption: String {
        case `public`, members, teachers
        case teachersAndStudents = "students,teachers"

        var string: String {
            switch self {
            case .public:
                return String(localized: "Anyone", bundle: .core)
            case .members:
                return String(localized: "Only members", bundle: .core)
            case .teachers:
                return String(localized: "Only teachers", bundle: .core)
            case .teachersAndStudents:
                return String(localized: "Teachers and students", bundle: .core)
            }
        }
    }
}

#if DEBUG
struct PageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PageEditorView(context: .course("1"), url: "page")
    }
}
#endif
