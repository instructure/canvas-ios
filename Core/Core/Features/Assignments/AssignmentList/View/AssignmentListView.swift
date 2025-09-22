//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct AssignmentListView: View {

    private let sections: [AssignmentListSection]
    private let identifierGroup: String
    private let navigateToDetailsAction: (URL?) -> Void

    init(
        sections: [AssignmentListSection],
        identifierGroup: String,
        navigateToDetailsAction: @escaping (URL?) -> Void
    ) {
        self.sections = sections
        self.identifierGroup = identifierGroup
        self.navigateToDetailsAction = navigateToDetailsAction
    }

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(sections) { section in
                sectionView(with: section)
            }
        }
    }

    private func sectionView(with section: AssignmentListSection) -> some View {
        InstUI.CollapsibleListSection(title: section.title, itemCount: section.rows.count) {
            ForEach(section.rows) { row in
                switch row {
                case .student(let model):
                    studentCell(model: model, isLastItem: section.rows.last == row)
                case .teacher(let model):
                    teacherCell(model: model, isLastItem: section.rows.last == row)
                }
            }
        }
    }

    @ViewBuilder
    private func studentCell(model: StudentAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetailsAction(model.route) }
        let identifier = "\(identifierGroup).\(model.id)"

        if let subItems = model.subItems {
            InstUI.CollapsibleListRow(
                cell: StudentAssignmentListItemCell(model: model, isLastItem: nil, action: routeAction)
                    .identifier(identifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subItems) { subItem in
                    StudentAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .identifier(identifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            StudentAssignmentListItemCell(model: model, isLastItem: isLastItem, action: routeAction)
                .identifier(identifier)
        }
    }

    @ViewBuilder
    private func teacherCell(model: TeacherAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetailsAction(model.route) }
        let identifier = "\(identifierGroup).\(model.id)"

        if let subItems = model.subItems {
            InstUI.CollapsibleListRow(
                cell: TeacherAssignmentListItemCell(model: model, isLastItem: nil, action: routeAction)
                    .identifier(identifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subItems) { subItem in
                    TeacherAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .identifier(identifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            TeacherAssignmentListItemCell(model: model, isLastItem: isLastItem, action: routeAction)
                .identifier(identifier)
        }
    }
}
