//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct AssignmentCellView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: AssignmentCellViewModel

    public init(viewModel: AssignmentCellViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button(action: {
            if let url = viewModel.route {
                env.router.route(to: url, from: controller, options: .detail)
            }
        }, label: {
            HStack(spacing: 13) {
                icon
                VStack(alignment: .leading, spacing: 0) {
                    assignmentName
                    dueDate
                    needsGradingBubble
                }
                .padding(.top, Typography.Spacings.textCellTopPadding)
                .padding(.bottom, Typography.Spacings.textCellBottomPadding)
                Spacer()
                InstDisclosureIndicator()
            }
            .padding(.trailing, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
            .background(Color.backgroundLightest)
            .buttonStyle(ContextButton(contextColor: viewModel.courseColor))
            .accessibility(identifier: "assignment-list.assignment-list-row.cell-\(viewModel.assignment.id)")
    }

    private var icon: some View {
        AccessIcon(image: viewModel.icon, published: viewModel.published)
            .frame(width: 20, height: 20)
            .foregroundColor(Color(viewModel.courseColor ?? .ash))
            .padding(.top, 10)
            .padding(.leading, 18)
            .frame(maxHeight: .infinity, alignment: .top)
    }

    private var assignmentName: some View {
        Text(viewModel.name)
            .style(.textCellTitle)
            .foregroundColor(.textDarkest)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
    }

    private var dueDate: some View {
        Text(viewModel.formattedDueDate)
            .style(.textCellSupportingText)
            .foregroundColor(.textDark)
    }

    @ViewBuilder
    private var needsGradingBubble: some View {
        if let needsGradingText = viewModel.needsGradingText {
            Text(needsGradingText)
                .font(.medium10)
                .foregroundColor(.borderInfo)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 9).stroke(Color.borderInfo, lineWidth: 1))
                .padding(.top, 6)
                .padding(.bottom, 5)
        }
    }
}

#if DEBUG

struct AssignmentCellView_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static let assignments: [APIAssignment] = [
        APIAssignment.make(name: "Assignment 1", needs_grading_count: 0),
        APIAssignment.make(id: "2", name: "Long titled assignment to test how layout behaves", quiz_id: "1"),
        APIAssignment.make(id: "3", submission_types: [.discussion_topic]),
        APIAssignment.make(id: "4", submission_types: [.external_tool]),
        APIAssignment.make(id: "5", locked_for_user: true)
    ]

    static var previews: some View {
        let list = VStack(spacing: 0) {
            Divider()
            ForEach(assignments, id: \.id) {
                let assignment = Assignment.save($0, in: context, updateSubmission: false, updateScoreStatistics: false)
                let viewModel = AssignmentCellViewModel(assignment: assignment, courseColor: .red)
                AssignmentCellView(viewModel: viewModel)
                Divider()
            }
        }.previewLayout(.sizeThatFits)

        list
        list.preferredColorScheme(.dark)
    }
}

#endif
