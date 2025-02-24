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

public struct SyllabusEditorView: View {
    let context: Context
    let courseID: String

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var html: String = ""
    @State var showSummary: Bool = false

    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var showError: Bool = false
    @State var error: Error? {
        didSet { showError = error != nil }
    }

    public init(context: Context, courseID: String) {
        self.context = context
        self.courseID = courseID
    }

    public var body: some View {
        form
            .navigationBarTitleView(String(localized: "Edit Syllabus", bundle: .core))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core)
                        .accessibilityIdentifier("SyllabusEditor.cancel")
                }),
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core)
                        .bold()
                        .accessibilityIdentifier("SyllabusEditor.done")
                })
                    .disabled(isLoading || isSaving)
            )
            .navigationBarStyle(.modal)

            .alert(isPresented: $showError) {
                Alert(title: Text(error!.localizedDescription))
            }

            .onAppear(perform: load)
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Content", bundle: .core)) {
                RichContentEditor(
                    env: env,
                    placeholder: String(localized: "Add content", bundle: .core),
                    a11yLabel: String(localized: "Syllabus content", bundle: .core),
                    html: $html,
                    uploadParameters: .init(context: context),
                    height: $rceHeight,
                    canSubmit: $rceCanSubmit,
                    error: $error
                )
                    .frame(height: max(200, rceHeight))
            }
            EditorSection(label: Text("Details", bundle: .core)) {
                Toggle(isOn: $showSummary) { Text("Show Course Summary", bundle: .core) }
                    .font(.semibold16).foregroundColor(.textDarkest)
                    .padding(16)
                    .identifier("SyllabusEditor.summaryToggle")
            }
        }
    }

    func loadCourseSettings() {
        let useCase = GetCourseSettings(courseID: courseID)
        useCase.fetch { _, _, _ in performUIUpdate {
            let settings: CourseSettings? = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.showSummary = settings?.syllabusCourseSummary == true
        } }
    }

    func load() {
        guard !isLoaded else { return }
        loadCourseSettings()
        let useCase = GetCourse(courseID: courseID)
        useCase.fetch { _, _, error in performUIUpdate {
            let course: Course? = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.html = course?.syllabusBody ?? ""
            self.isLoading = false
            self.isLoaded = true
            self.error = error
        } }
    }

    func save() {
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        UpdateCourse(courseID: courseID, syllabusBody: html, syllabusSummary: showSummary).fetch { result, _, error in performUIUpdate {
                self.error = error
                self.isSaving = false
                if result != nil {
                    env.router.dismiss(controller)
                }
            }
        }
    }
}

#if DEBUG
struct SyllabusEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SyllabusEditorView(context: .course("1"), courseID: "1")
    }
}
#endif
