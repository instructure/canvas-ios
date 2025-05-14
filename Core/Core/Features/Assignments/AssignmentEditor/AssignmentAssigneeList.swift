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

struct AssigmentAssigneeList: View {
    typealias Assignee = AssignmentAssigneePicker.Assignee

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject var groups: Store<GetGroupsInCategory>
    @ObservedObject var sections: Store<GetCourseSections>
    @ObservedObject var students: Store<GetContextUsers>

    @Binding var selection: [Assignee]

    let everyone = String(localized: "Everyone", bundle: .core)
    @State var search: String = ""

    var isEveryoneMatching: Bool {
        let value = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty || everyone.localizedCaseInsensitiveContains(value)
    }

    var isEmpty: Bool {
        !isEveryoneMatching && sections.isEmpty && groups.isEmpty && students.isEmpty
    }

    init(courseID: String, groupCategoryID: String?, selection: Binding<[Assignee]>) {
        groups = AppEnvironment.shared.subscribe(GetGroupsInCategory(groupCategoryID))
        sections = AppEnvironment.shared.subscribe(GetCourseSections(courseID: courseID))
        students = AppEnvironment.shared.subscribe(GetContextUsers(context: .course(courseID), type: .student))
        _selection = selection
    }

    var body: some View {
        GeometryReader { geometry in VStack(spacing: 0) {
            SearchBar(
                text: Binding(get: { search }, set: { updateSearch($0) }),
                placeholder: String(localized: "Search", bundle: .core)
            )
            ScrollView {
                if isEmpty {
                    EmptyPanda(.NoResults, message: Text("We couldn’t find somebody like that.", bundle: .core))
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                } else {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) { list }
                }
            }
                .background((isEmpty ? Color.backgroundLightest : Color.backgroundGrouped).edgesIgnoringSafeArea(.all))
        } }
            .navigationBarTitleView(String(localized: "Add Assignee", bundle: .core))
            .navigationBarStyle(.modal)
    }

    @ViewBuilder
    var list: some View {
        Divider().padding(.top, -1)
        if isEveryoneMatching {
            ButtonRow(action: { select(.everyone) }, content: {
                Avatar.Anonymous(isGroup: true)
                    .padding(.trailing, 16)
                Text(everyone)
                Spacer()
                if selection.contains(.everyone) {
                    Image.checkSolid.foregroundColor(.accentColor)
                }
            })
            Divider()
        }

        if !sections.isEmpty { Section(header: ListSectionHeaderOld { Text("Course Sections", bundle: .core) }) {
            Divider()
            ForEach(sections.all, id: \.id) { section in
                ButtonRow(action: { select(.section(section.id)) }, content: {
                    Avatar(name: section.name, url: nil)
                        .padding(.trailing, 16)
                    Text(section.name)
                    Spacer()
                    if selection.contains(.section(section.id)) {
                        Image.checkSolid.foregroundColor(.accentColor)
                    }
                })
                Divider()
            }
        } }

        if !groups.isEmpty { Section(header: ListSectionHeaderOld { Text("Groups", bundle: .core) }) {
            Divider()
            ForEach(groups.all, id: \.id) { group in
                ButtonRow(action: { select(.group(group.id)) }, content: {
                    Avatar(name: group.name, url: group.avatarURL)
                        .padding(.trailing, 16)
                    Text(group.name)
                    Spacer()
                    if selection.contains(.group(group.id)) {
                        Image.checkSolid.foregroundColor(.accentColor)
                    }
                })
                Divider()
            }
        } }

        if !students.isEmpty { Section(header: ListSectionHeaderOld { Text("Students", bundle: .core) }) {
            Divider()
            ForEach(students.all, id: \.id) { student in
                ButtonRow(action: { select(.student(student.id)) }, content: {
                    Avatar(name: student.name, url: student.avatarURL)
                        .padding(.trailing, 16)
                    Text(student.displayName)
                    Spacer()
                    if selection.contains(.student(student.id)) {
                        Image.checkSolid.foregroundColor(.accentColor)
                    }
                })
                Divider()
            }
        } }
    }

    func updateSearch(_ newValue: String) {
        withAnimation(.default) {
            let value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if value.isEmpty {
                groups.setScope(groups.useCase.scope)
                sections.setScope(sections.useCase.scope)
                students.setScope(students.useCase.scope)
            } else {
                groups.setScope(searchScope(groups.useCase.scope, key: #keyPath(Group.name), value: value))
                sections.setScope(searchScope(sections.useCase.scope, key: #keyPath(CourseSection.name), value: value))
                students.setScope(searchScope(students.useCase.scope, key: #keyPath(User.name), value: value))
            }
            search = newValue
        }
    }

    func searchScope(_ original: Scope, key: String, value: String) -> Scope {
        Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            original.predicate,
            NSPredicate(format: "%K CONTAINS[cd] %@", key, value)
        ]), order: original.order)
    }

    func select(_ assignee: Assignee) {
        if !selection.contains(assignee) {
            selection.append(assignee)
        }
        env.router.pop(from: controller)
    }
}
