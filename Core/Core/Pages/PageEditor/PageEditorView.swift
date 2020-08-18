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

@available(iOSApplicationExtension 13.0.0, *)
public struct PageEditorView: View {
    let context: Context
    let url: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var viewController

    @State var title: String = ""
    @State var html: String = ""
    @State var editingRoles: RoleOption = .members
    @State var published: Bool = false
    @State var isFrontPage: Bool = false

    @State var isLoading = true
    @State var isSaving = false
    @State var editingRolesPickerShown: Bool = false
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
        ZStack {
            form.disabled(isLoading || isSaving)
            if isLoading || isSaving {
                CircleProgress().size()
            }
        }
            .alert(isPresented: $showError) {
                Alert(title: Text(verbatim: ""), message: Text(error!.localizedDescription))
            }
            .avoidKeyboardArea()
            .background(Color.backgroundGrouped)
            .navigationBarTitle(url == nil ? Text("New Page", bundle: .core) : Text("Edit Page", bundle: .core), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    guard let controller = self.viewController() else { return }
                    self.env.router.dismiss(controller)
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
            .navBarStyle(.modal)
            .onAppear(perform: load)
    }

    var form: some View {
        ScrollView { VStack(alignment: .leading, spacing: 0) {
            if env.app == .teacher {
                Text("Title", bundle: .core)
                    .font(.semibold14).foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                Divider()
                TextField("Add Title", text: $title)
                    .font(.regular16).foregroundColor(.textDarkest)
                    .padding(16)
                    .background(Color.backgroundLightest)
                    .identifier("PageEditor.titleField")
                Divider()
            } else {
                Text(title)
                    .font(.bold20).foregroundColor(.textDarkest)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .identifier("PageEditor.titleText")
            }

            Text("Content", bundle: .core)
                .font(.semibold14).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            Divider()
            RichContentEditor(
                placeholder: NSLocalizedString("Add content", bundle: .core, comment: ""),
                html: $html,
                context: context,
                uploadTo: .context(context),
                height: $rceHeight,
                canSubmit: $rceCanSubmit,
                error: $error
            )
                .background(Color.backgroundLightest)
                .frame(minHeight: 200, idealHeight: max(200, rceHeight))
            Divider()

            if env.app == .teacher || context.contextType == .group {
                Text("Details", bundle: .core)
                    .font(.semibold14).foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                Divider()
                if url != "front_page" && env.app == .teacher {
                    Toggle(isOn: $published) { Text("Publish", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .background(Color.backgroundLightest)
                        .disabled(isFrontPage)
                        .identifier("PageEditor.publishedToggle")
                    Divider()
                }
                if url != "front_page" && env.app == .teacher {
                    Toggle(isOn: $isFrontPage) { Text("Set as Front Page", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .background(Color.backgroundLightest)
                        .disabled(!published)
                        .identifier("PageEditor.frontPageToggle")
                    Divider()
                }
                Button(action: { self.editingRolesPickerShown.toggle() }, label: {
                    Text("Can Edit", bundle: .core).font(.semibold16)
                    Spacer()
                    editingRoles.text
                    Image(systemName: "chevron.right")
                        .flipsForRightToLeftLayoutDirection(true)
                        .accentColor(.borderMedium)
                })
                    .padding(16)
                    .accentColor(.textDarkest)
                    .background(Color.backgroundLightest)
                    .identifier("PageEditor.editorsButton")
                Divider()
                if editingRolesPickerShown {
                    Picker(selection: $editingRoles, label: Text("Can Edit", bundle: .core), content: {
                        if context.contextType == .group {
                            RoleOption.members.text
                        } else {
                            RoleOption.teachers.text
                            RoleOption.teachersAndStudents.text
                        }
                        RoleOption.public.text
                    })
                        .labelsHidden()
                        .identifier("PageEditor.editorsPicker")
                }
            }
        } }
    }

    func load() {
        guard let url = url else {
            editingRoles = context.contextType == .group ? .members : .teachers
            isLoading = false
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
            self.error = error
        } }
    }

    func save() {
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
            if result != nil, let controller = self.viewController() {
                self.env.router.dismiss(controller)
            }
        } }
    }

    enum RoleOption: String {
        case `public`, members, teachers
        case teachersAndStudents = "students,teachers"

        var text: some View {
            switch self {
            case .public:
                return Text("Anyone", bundle: .core).tag(self)
            case .members:
                return Text("Only members", bundle: .core).tag(self)
            case .teachers:
                return Text("Only teachers", bundle: .core).tag(self)
            case .teachersAndStudents:
                return Text("Teachers and students", bundle: .core).tag(self)
            }
        }
    }
}

#if DEBUG
@available(iOSApplicationExtension 13.0.0, *)
struct PageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PageEditorView(context: .course("1"), url: "page")
    }
}
#endif
