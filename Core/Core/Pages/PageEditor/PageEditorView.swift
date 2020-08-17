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
    @State var editingRoles: String = "members"
    @State var published: Bool = false
    @State var isFrontPage: Bool = false

    @State var isLoading = true
    @State var isSaving = false
    @State var editingRolesPickerShown: Bool = false
    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var rceError: Error?
    @State var saveError: Error?

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
            .background(Color.backgroundGrouped)
            .navigationBarTitle(url == nil ? Text("New Page") : Text("Edit Page"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    guard let controller = self.viewController() else { return }
                    self.env.router.dismiss(controller)
                }, label: {
                    Text("Cancel")
                })
                    .identifier("screen.dismiss"),
                trailing: Button(action: save, label: {
                    Text("Done").bold()
                })
                    .disabled(isLoading || isSaving)
                    .identifier("PageEditor.doneButton")
            )
            .onAppear(perform: load)
    }

    var form: some View {
        ScrollView { VStack(alignment: .leading, spacing: 0) {
            if env.app == .teacher {
                Text("Title")
                    .font(.semibold14).foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                Divider()
                TextField("Add Title", text: $title)
                    .foregroundColor(.textDarkest)
                    .padding(16)
                    .background(Color.backgroundLightest)
                    .identifier("PageEditor.titleField")
                Divider()
            } else {
                Text(title)
                    .font(.bold20)
                    .foregroundColor(.textDarkest)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .identifier("PageEditor.titleText")
            }

            Text("Content")
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
                error: $rceError
            )
                .frame(minHeight: 60, idealHeight: max(60, rceHeight))
            Divider()

            if env.app == .teacher || context.contextType == .group {
                Text("Details")
                    .font(.semibold14).foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                Divider()
                if !isFrontPage && env.app == .teacher {
                    Toggle("Publish", isOn: $published)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .background(Color.backgroundLightest)
                        .identifier("PageEditor.publishedToggle")
                    Divider()
                }
                if published && url != "front_page" && env.app == .teacher {
                    Toggle("Set as Front Page", isOn: $isFrontPage)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .background(Color.backgroundLightest)
                        .identifier("PageEditor.frontPageToggle")
                    Divider()
                }
                Button(action: { self.editingRolesPickerShown.toggle() }, label: {
                    Text("Can Edit").font(.semibold16)
                    Spacer()
                    if editingRoles == "members" {
                        Text("Only members")
                    } else if editingRoles == "teachers" {
                        Text("Only teachers")
                    } else if editingRoles == "students,teachers" {
                        Text("Teachers and students")
                    } else if editingRoles == "public" {
                        Text("Anyone")
                    }
                    Image(systemName: "chevron.right").accentColor(.borderMedium)
                })
                    .padding(16)
                    .accentColor(.textDarkest)
                    .background(Color.backgroundLightest)
                    .identifier("PageEditor.editorsButton")
                Divider()
                if editingRolesPickerShown {
                    Picker("Can Edit", selection: $editingRoles) {
                        if context.contextType == .group {
                            Text("Only members").tag("members")
                        } else {
                            Text("Only teachers").tag("teachers")
                            Text("Teachers and students").tag("students,teachers")
                        }
                        Text("Anyone").tag("public")
                    }
                        .labelsHidden()
                        .identifier("PageEditor.editorsPicker")
                }
            }
        } }
    }

    func load() {
        guard let url = url else {
            isLoading = false
            return
        }
        let useCase = GetPage(context: context, url: url)
        useCase.fetch { _, _, _ in performUIUpdate {
            let page: Page? = self.env.database.viewContext.fetch(scope: useCase.scope).first
            var editingRoles = "public"
            if page?.editingRoles.contains("teachers") == true { editingRoles = "teachers" }
            if page?.editingRoles.contains("students") == true { editingRoles = "students,teachers" }
            if page?.editingRoles.contains("members") == true { editingRoles = "members" }
            self.title = page?.title ?? ""
            self.html = page?.body ?? ""
            self.editingRoles = editingRoles
            self.published = page?.published ?? false
            self.isFrontPage = page?.isFrontPage ?? false
            self.isLoading = false
        } }
    }

    func save() {
        isSaving = true
        UpdatePage(
            context: context,
            url: url,
            title: title,
            body: html,
            editing_roles: editingRoles,
            published: published || isFrontPage,
            front_page: isFrontPage
        ).fetch { result, _, error in performUIUpdate {
            self.saveError = error
            self.isSaving = false
            if result != nil, let controller = self.viewController() {
                self.env.router.dismiss(controller)
            }
        } }
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
