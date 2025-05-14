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

struct AssignmentAssigneePicker: View {
    typealias Override = AssignmentOverridesEditor.Override

    let courseID: String
    let groupCategoryID: String?
    let override: Override

    @Binding var overrides: [Override]

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var selection: [Assignee]

    @ObservedObject var groups: Store<GetGroupsInCategory>
    @ObservedObject var sections: Store<GetCourseSections>
    @ObservedObject var students: Store<GetContextUsers>

    var isSpinning: Bool {
        groups.state == .loading || sections.state == .loading || students.state == .loading
    }

    init(courseID: String, groupCategoryID: String?, overrides: Binding<[Override]>, override: Override) {
        self.courseID = courseID
        self.groupCategoryID = groupCategoryID
        self.override = override
        self._overrides = overrides
        self._selection = State(initialValue: Assignee.from(override))

        groups = AppEnvironment.shared.subscribe(GetGroupsInCategory(groupCategoryID))
        sections = AppEnvironment.shared.subscribe(GetCourseSections(courseID: courseID))
        students = AppEnvironment.shared.subscribe(GetContextUsers(context: .course(courseID), type: .student))
    }

    var body: some View {
        form
            .navigationBarTitleView(String(localized: "Assign to", bundle: .core))
            .navigationBarItems(
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                .disabled(isSpinning)
                .identifier("DiscussionEditor.doneButton")
            )
            .navigationBarStyle(.modal)
            .onAppear(perform: load)
    }

    var form: some View {
        EditorForm(isSpinning: isSpinning) { if !isSpinning {
            if !selection.isEmpty { EditorSection {
                ForEach(selection) { assignee in
                    if selection.first != assignee { Divider() }
                    editorRow(assignee)
                }
            } }
            EditorSection { ButtonRow(action: add, content: {
                Image.addSolid.size(18)
                    .padding(.trailing, 12)
                Text("Add Assignee", bundle: .core)
                Spacer()
                InstUI.DisclosureIndicator()
            }) }
        } }
    }

    private func editorRow(_ assignee: Assignee) -> some View {
        EditorRow {
            switch assignee {
            case .everyone:
                Avatar.Anonymous(isGroup: true)
                    .padding(.trailing, 16).padding(.vertical, -4)
                if selection.count <= 1 {
                    Text("Everyone", bundle: .core)
                } else {
                    Text("Everyone else", bundle: .core)
                }
            case .group(let id):
                let group = self.group(id)
                Avatar(name: group?.name, url: group?.avatarURL)
                    .padding(.trailing, 16).padding(.vertical, -4)
                group.map { Text($0.name) }
            case .section(let id):
                let section = self.section(id)
                Avatar(name: section?.name, url: nil)
                    .padding(.trailing, 16).padding(.vertical, -4)
                section.map { Text($0.name) }
            case .student(let id):
                let student = self.student(id)
                Avatar(name: student?.name, url: student?.avatarURL)
                    .padding(.trailing, 16).padding(.vertical, -4)
                student.map { Text($0.displayName) }
            }
            Spacer()
            Button(action: { withAnimation(.default) {
                selection = selection.filter { $0 != assignee }
            } }, label: {
                Image.xLine.foregroundColor(.textDark)
            })
        }
    }

    func load() {
        guard !students.requested else { return }
        groups.exhaust()
        sections.exhaust()
        students.exhaust()
    }

    func group(_ id: String) -> Group? { groups.first { $0.id == id } }
    func section(_ id: String) -> CourseSection? { sections.first { $0.id == id } }
    func student(_ id: String) -> User? { students.first { $0.id == id } }

    func add() {
        env.router.show(CoreHostingController(AssigmentAssigneeList(
            courseID: courseID, groupCategoryID: groupCategoryID, selection: $selection
        )), from: controller)
    }

    func save() {
        guard selection != Assignee.from(override) else {
            return env.router.pop(from: controller)
        }
        overrides = overrides.flatMap { item -> [Override] in
            guard item == override else { return [item] }
            var replaceWith: [Override] = []
            var studentIDs: [String] = []
            for assignee in selection {
                switch assignee {
                case .everyone:
                    replaceWith.append(createOverride(title: nil))
                case .group(let id):
                    replaceWith.append(createOverride(groupID: id, title: group(id)?.name ?? id))
                case .section(let id):
                    replaceWith.append(createOverride(sectionID: id, title: section(id)?.name ?? id))
                case .student(let id):
                    studentIDs.append(id)
                }
            }
            if !studentIDs.isEmpty || replaceWith.isEmpty {
                replaceWith.insert(createOverride(
                    studentIDs: studentIDs,
                    title: Override.studentsString(studentIDs.count)
                ), at: replaceWith.firstIndex { $0.isEveryone } ?? replaceWith.count)
            }
            return replaceWith
        }
        env.router.pop(from: controller)
    }

    func createOverride(groupID: String? = nil, sectionID: String? = nil, studentIDs: [String]? = nil, title: String?) -> Override {
        return Override(
            dueAt: override.dueAt,
            id: UUID.string,
            groupID: groupID,
            lockAt: override.lockAt,
            sectionID: sectionID,
            studentIDs: studentIDs,
            title: title,
            unlockAt: override.unlockAt
        )
    }

    enum Assignee: Equatable, Identifiable {
        case everyone
        case group(String)
        case section(String)
        case student(String)

        var id: String { String(describing: self) }

        static func from(_ override: Override) -> [Assignee] {
            if let id = override.groupID {
                return [.group(id)]
            } else if let id = override.sectionID {
                return [.section(id)]
            } else if let ids = override.studentIDs {
                return ids.map { Assignee.student($0) }
            }
            return [.everyone]
        }
    }
}
