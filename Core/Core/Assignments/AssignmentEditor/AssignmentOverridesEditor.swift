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

public struct AssignmentOverridesEditor: View {
    let courseID: String
    let groupCategoryID: String?
    @Binding var overrides: [Override]
    @Binding var toRemove: Override?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    public var body: some View {
        ForEach(overrides) { override in

            let dueAt = Binding(get: { override.dueAt }, set: { set(override, \.dueAt, $0) })
            let unlockAt = Binding(get: { override.unlockAt }, set: { set(override, \.unlockAt, $0) })
            let lockAt = Binding(get: { override.lockAt }, set: { set(override, \.lockAt, $0) })

            EditorSection(label: HStack {
                Text("Assign", bundle: .core)
                Spacer()
                Button(action: { toRemove = override }, label: {
                    Text("Remove", bundle: .core)
                        .foregroundColor(Color(Brand.shared.linkColor))
                })
            }) {
                ButtonRow(action: { pickAssignee(for: override) }, content: {
                    Text("Assign to", bundle: .core)
                    Spacer()
                    Text(override.title ?? everyone)
                        .font(.medium16).foregroundColor(.textDark)
                    Spacer().frame(width: 16)
                    DisclosureIndicator()
                })
                Divider()

                ButtonRow(action: { CoreDatePicker.showDatePicker(for: dueAt, from: controller) }, content: {
                    Text("Due", bundle: .core)
                    Spacer()
                    if let dueAt = dueAt.wrappedValue {
                        Text(DateFormatter.localizedString(from: dueAt, dateStyle: .medium, timeStyle: .short))
                    }
                })
                Divider()
                ButtonRow(action: { CoreDatePicker.showDatePicker(for: unlockAt, maxDate: lockAt.wrappedValue, from: controller) }, content: {
                    Text("Available from", bundle: .core)
                    Spacer()
                    if let unlockAt = unlockAt.wrappedValue {
                        Text(DateFormatter.localizedString(from: unlockAt, dateStyle: .medium, timeStyle: .short))
                    }
                })
                Divider()
                ButtonRow(action: { CoreDatePicker.showDatePicker(for: lockAt, minDate: unlockAt.wrappedValue, from: controller) }, content: {
                    Text("Available until", bundle: .core)
                    Spacer()
                    if let lockAt = lockAt.wrappedValue {
                        Text(DateFormatter.localizedString(from: lockAt, dateStyle: .medium, timeStyle: .short))
                    }
                })
                Divider()
            }
        }
        EditorSection {
            ButtonRow(action: add, content: {
                Image.addSolid.size(18)
                    .foregroundColor(Color(Brand.shared.linkColor))
                    .padding(.trailing, 12)
                Text("Add Due Date", bundle: .core)
                    .foregroundColor(Color(Brand.shared.linkColor))
                Spacer()
            })
        }
    }

    var everyone: String {
        overrides.count <= 1 ? NSLocalizedString("Everyone", comment: "") : NSLocalizedString("Everyone else", comment: "")
    }

    func add() {
        withAnimation(.default) {
            let everyone = overrides.last { $0.isEveryone }
            overrides.append(Override(
                dueAt: everyone?.dueAt,
                id: UUID.string,
                groupID: nil,
                lockAt: everyone?.lockAt,
                sectionID: nil,
                studentIDs: [],
                title: Override.studentsString(0),
                unlockAt: everyone?.unlockAt
            ))
        }
    }

    func set(_ override: Override, _ key: WritableKeyPath<Override, Date?>, _ value: Date?) {
        guard let index = overrides.firstIndex(of: override) else { return }
        overrides[index][keyPath: key] = value
    }

    func pickAssignee(for override: Override) {
        let picker = AssignmentAssigneePicker(
            courseID: courseID,
            groupCategoryID: groupCategoryID,
            overrides: $overrides,
            override: override
        )
        env.router.show(CoreHostingController(picker), from: controller)
    }

    static func alert(toRemove: Override, from overrides: Binding<[Override]>) -> Alert {
        Alert(
            title: Text("Remove Due Date?", bundle: .core),
            message: Text("This will remove the due date and all of the associated assignees.", bundle: .core),
            primaryButton: .destructive(Text("Remove", bundle: .core)) {
                withAnimation(.default) {
                    overrides.wrappedValue = overrides.wrappedValue.filter { $0 != toRemove }
                }
            },
            secondaryButton: .cancel()
        )
    }

    static func overrides(from assignment: Assignment) -> [Override] {
        var overrides = assignment.overrides.map { (model: AssignmentOverride) -> Override in
            return Override(
                dueAt: model.dueAt,
                id: model.id,
                groupID: model.groupID,
                lockAt: model.lockAt,
                sectionID: model.courseSectionID,
                studentIDs: model.studentIDs,
                title: model.title,
                unlockAt: model.unlockAt
            )
        } .sorted { $0.id < $1.id }
        // Everyone
        if assignment.onlyVisibleToOverrides == false, let base = assignment.allDates.first(where: { $0.base }) {
            overrides.append(Override(
                dueAt: base.dueAt,
                id: "base",
                groupID: nil,
                lockAt: base.lockAt,
                sectionID: nil,
                studentIDs: nil,
                title: nil,
                unlockAt: base.unlockAt
            ))
        }
        return overrides
    }

    static func apiOverrides(for assignmentID: String, from: [Override]) -> (dueAt: Date?, unlockAt: Date?, lockAt: Date?, overrides: [APIAssignmentOverride]) {
        var dueAt: Date?, unlockAt: Date?, lockAt: Date?, overrides: [APIAssignmentOverride] = []
        for override in from where override.studentIDs?.isEmpty != true {
            if let title = override.title, !override.isEveryone {
                overrides.append(APIAssignmentOverride(
                    assignment_id: ID(assignmentID),
                    course_section_id: ID(override.sectionID),
                    due_at: override.dueAt,
                    group_id: ID(override.groupID),
                    id: ID(override.id),
                    lock_at: override.lockAt,
                    student_ids: override.studentIDs?.map { ID($0) },
                    title: title,
                    unlock_at: override.unlockAt
                ))
            } else {
                dueAt = override.dueAt
                unlockAt = override.unlockAt
                lockAt = override.lockAt
            }
        }
        return (dueAt: dueAt, unlockAt: unlockAt, lockAt: lockAt, overrides: overrides)
    }

    public struct Override: Equatable, Identifiable {
        var dueAt: Date?
        public var id: String
        let groupID: String?
        var lockAt: Date?
        let sectionID: String?
        let studentIDs: [String]?
        var title: String?
        var unlockAt: Date?

        var isEveryone: Bool { groupID == nil && sectionID == nil && studentIDs == nil }

        static func studentsString(_ count: Int) -> String {
            return String.localizedStringWithFormat(NSLocalizedString("%d students", comment: ""), count)
        }
    }
}
