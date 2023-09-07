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
import mobile_offline_downloader_ios

struct CustomizeCourseView: View {
    let course: Course
    let hideColorOverlay: Bool
    let imageDownloadURL: URL?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var color: UIColor
    @State var error: AlertError?
    @State var isSaving = false
    @State var name: String

    static let colors: KeyValuePairs<String, Text> = [
        "#BD3C14": Text("Brick", bundle: .core),
        "#FF2717": Text("Red", bundle: .core),
        "#E71F63": Text("Magenta", bundle: .core),
        "#8F3E97": Text("Purple", bundle: .core),
        "#65499D": Text("Deep Purple", bundle: .core),
        "#4554A4": Text("Indigo", bundle: .core),
        "#1770AB": Text("Blue", bundle: .core),
        "#0B9BE3": Text("Light Blue", bundle: .core),
        "#06A3B7": Text("Cyan", bundle: .core),
        "#009688": Text("Teal", bundle: .core),
        "#009606": Text("Green", bundle: .core),
        "#8D9900": Text("Olive", bundle: .core),
        "#D97900": Text("Pumpkin", bundle: .core),
        "#FD5D10": Text("Orange", bundle: .core),
        "#F06291": Text("Pink", bundle: .core),
    ]

    init(course: Course, hideColorOverlay: Bool) {
        self.course = course
        self.hideColorOverlay = hideColorOverlay
        imageDownloadURL = course.imageDownloadURL
        _color = State(initialValue: course.color)
        _name = State(initialValue: course.name ?? "")
    }

    var body: some View { GeometryReader { geometry in
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
                label: Text("Nickname", bundle: .core),
                placeholder: NSLocalizedString("Add Course Nickname", comment: ""),
                text: $name
            )
            Divider()
            EditorRow { VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Color", bundle: .core)
                    Spacer()
                }
                    .padding(.bottom, 2)
                Text("This is your personal color setting. Only you will see this color for the course.", bundle: .core)
                    .font(.medium14).foregroundColor(.textDark)
                    .fixedSize(horizontal: false, vertical: true)

                JustifiedGrid(
                    itemCount: Self.colors.count,
                    itemSize: CGSize(width: 48, height: 48), spacing: 8,
                    width: width - 32 // account for padding
                ) { itemIndex in
                    let item = Self.colors[itemIndex]
                    let uiColor = UIColor(hexString: item.key) ?? .ash
                    let isSelected = uiColor.difference(to: color) < 0.02
                    Button(action: { color = uiColor }, label: {
                        Circle().fill(Color(uiColor))
                            .overlay(isSelected ? Image.checkSolid.foregroundColor(.white) : nil)
                    })
                        .buttonStyle(ScaleButtonStyle(scale: 0.9))
                        .accessibility(addTraits: isSelected ? .isSelected : [])
                        .accessibility(label: item.value)
                }
                    .padding(.vertical, 12)
            } }
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

            .alert(item: $error) { error in
                Alert(title: Text(error.error.localizedDescription))
            }
    } }

    struct AlertError: Identifiable {
        let error: Error
        var id: String { error.localizedDescription }
    }

    func save() {
        defer {
            update(color: color.hexString, name: name)
        }
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        guard name != course.name else { return saveColor() }
        UpdateCourseNickname(courseID: course.id, nickname: name).fetch { result, _, fetchError in performUIUpdate {
            error = fetchError.map { AlertError(error: $0) }
            if result != nil {
                saveColor()
            } else {
                isSaving = false
            }
        } }
    }

    func saveColor() {
        guard color.difference(to: course.color) >= 0.02 else {
            isSaving = false
            return env.router.dismiss(controller)
        }
        UpdateCustomColor(context: .course(course.id), color: color.hexString).fetch { result, _, fetchError in performUIUpdate {
            error = fetchError.map { AlertError(error: $0) }
            isSaving = false
            if result != nil {
                env.router.dismiss(controller)
            }
        } }
    }

    func cancel() {
        controller.view.endEditing(true) // dismiss keyboard
        env.router.dismiss(controller)
    }

    private func update(color: String?, name: String?) {
        OfflineStorageManager.shared.load(
            for: CourseStorageDataModel.configureId(id: course.id),
            castingType: CourseStorageDataModel.self
        ) { result in
            result.success { courseStorageDataModel in
                name.flatMap {
                    courseStorageDataModel.course.name = $0
                }
                color.flatMap {
                    courseStorageDataModel.course.courseColor = $0
                }
                OfflineStorageManager.shared.save(courseStorageDataModel) { _ in }
            }
        }
    }
}
