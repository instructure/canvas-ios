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
    private let selectedAssignmentId: String?
    private let navigateToDetailsAction: (URL?, String) -> Void
    private let whatIfModel: GradeListWhatIfModel?

    init(
        sections: [AssignmentListSection],
        identifierGroup: String,
        selectedAssignmentId: String?,
        navigateToDetailsAction: @escaping (URL?, String) -> Void,
        whatIfModel: GradeListWhatIfModel? = nil
    ) {
        self.sections = sections
        self.identifierGroup = identifierGroup
        self.selectedAssignmentId = selectedAssignmentId
        self.navigateToDetailsAction = navigateToDetailsAction
        self.whatIfModel = whatIfModel
    }

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(sections) { section in
                AssignmentListSectionView(
                    section: section,
                    identifierGroup: identifierGroup,
                    selectedAssignmentId: selectedAssignmentId,
                    navigateToDetailsAction: navigateToDetailsAction,
                    whatIfModel: whatIfModel
                )
            }
        }
    }
}

// Sections are extracted to their own view, mainly to be able to conform to Equatable.
struct AssignmentListSectionView: View {
    private let section: AssignmentListSection
    private let sectionIdentifier: String
    private let itemIdentifierGroup: String
    private let selectedAssignmentId: String?
    private let navigateToDetailsAction: (URL?, String) -> Void
    private let whatIfModel: GradeListWhatIfModel?

    init(
        section: AssignmentListSection,
        identifierGroup: String,
        selectedAssignmentId: String?,
        navigateToDetailsAction: @escaping (URL?, String) -> Void,
        whatIfModel: GradeListWhatIfModel? = nil
    ) {
        self.section = section
        self.sectionIdentifier = "\(identifierGroup).Sections.\(section.id)"
        self.itemIdentifierGroup = "\(identifierGroup).Items"
        self.selectedAssignmentId = selectedAssignmentId
        self.navigateToDetailsAction = navigateToDetailsAction
        self.whatIfModel = whatIfModel
    }

    var body: some View {
        InstUI.CollapsibleListSection(
            title: section.title,
            headerIdentifier: sectionIdentifier,
            itemCount: section.rows.count
        ) {
            ForEach(section.rows) { row in
                cell(for: row, isLastItem: section.rows.last?.id == row.id)
                    .selected(when: row.id == selectedAssignmentId)
            }
        }
    }

    @ViewBuilder
    private func cell(for row: AssignmentListSection.Row, isLastItem: Bool) -> some View {
        switch row {
        case .student(let model):
            studentCell(model: model, isLastItem: isLastItem)
        case .teacher(let model):
            teacherCell(model: model, isLastItem: isLastItem)
        case .gradeListRow(let model):
            gradeListCell(model: model, isLastItem: isLastItem)
        }
    }

    @ViewBuilder
    private func studentCell(model: StudentAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetailsAction(model.route, model.id) }
        let itemIdentifier = "\(itemIdentifierGroup).\(model.id)"

        if let subItems = model.subItems {
            InstUI.CollapsibleListRow(
                cell: StudentAssignmentListItemCell(model: model, isLastItem: nil, action: routeAction)
                    .identifier(itemIdentifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subItems) { subItem in
                    StudentAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .selectionIndicatorDisabled()
                        .identifier(itemIdentifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            StudentAssignmentListItemCell(model: model, isLastItem: isLastItem, action: routeAction)
                .identifier(itemIdentifier)
        }
    }

    @ViewBuilder
    private func teacherCell(model: TeacherAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetailsAction(model.route, model.id) }
        let itemIdentifier = "\(itemIdentifierGroup).\(model.id)"

        if let subItems = model.subItems {
            InstUI.CollapsibleListRow(
                cell: TeacherAssignmentListItemCell(model: model, isLastItem: nil, action: routeAction)
                    .identifier(itemIdentifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subItems) { subItem in
                    TeacherAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .selectionIndicatorDisabled()
                        .identifier(itemIdentifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            TeacherAssignmentListItemCell(model: model, isLastItem: isLastItem, action: routeAction)
                .identifier(itemIdentifier)
        }
    }

    @ViewBuilder
    private func gradeListCell(model: StudentAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetailsAction(model.route, model.id) }
        let itemIdentifier = "\(itemIdentifierGroup).\(model.id)"

        if let subItems = model.subItems {
            InstUI.CollapsibleListRow(
                cell: GradeListItemCell(
                    model: model,
                    whatIfModel: whatIfModel,
                    isLastItem: nil,
                    action: routeAction
                )
                .identifier(itemIdentifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subItems) { subItem in
                    StudentAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .selectionIndicatorDisabled()
                        .identifier(itemIdentifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            GradeListItemCell(
                model: model,
                whatIfModel: whatIfModel,
                isLastItem: isLastItem,
                action: routeAction
            )
            .identifier(itemIdentifier)
        }
    }
}

extension AssignmentListSectionView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.section == rhs.section
        && lhs.selectedAssignmentId == rhs.selectedAssignmentId
    }
}
