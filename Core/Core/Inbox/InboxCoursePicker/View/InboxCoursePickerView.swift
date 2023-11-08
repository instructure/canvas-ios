//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct InboxCoursePickerView: View {
    @ObservedObject private var viewModel: InboxCoursePickerViewModel

    init(viewModel: InboxCoursePickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitleStyled(Text("Select Course", bundle: .core).font(.semibold17).foregroundColor(.textDarkest))
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            case .data:
                VStack(spacing: 0) {
                    courses(courses: viewModel.courses)
                    groups(groups: viewModel.groups)
                }
            case .empty, .error:
                Text("Some error occured", bundle: .core)
            }
        }
    }

    private func error(message: String) -> some View {
        Text(message)
            .font(.regular17)
            .foregroundColor(.textDarkest)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private func courses(courses: [Course]) -> some View {
        VStack(spacing: 0) {
            headerView(NSLocalizedString("Courses", bundle: .core, comment: ""))
                .accessibilitySortPriority(5)
            ForEach(courses, id: \.id) { course in
                courseRow(course)
            }
        }
    }

    private func groups(groups: [Group]) -> some View {
        VStack(spacing: 0) {
            headerView(NSLocalizedString("Groups", bundle: .core, comment: ""))
            ForEach(groups, id: \.id) { group in
                groupRow(group)
            }
        }
    }

    private func headerView(_ header: String) -> some View {
        VStack(spacing: 0) {
            separator
            Text(header)
                .font(.regular14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.textDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(Color.backgroundLight)
            separator
        }
    }

    private func courseRow(_ course: Course) -> some View {
        let courseName = course.name ?? course.courseCode ?? ""
        return VStack(spacing: 0) {
            HStack {
                Circle().fill(Color(course.color)).frame(width: 20, height: 20)
                    .padding(.leading, 22).padding(.trailing, 12)
                Text(courseName)
                    .font(.regular16)
                Spacer()
                if viewModel.selectedRecipientContext?.id == course.id, viewModel.selectedRecipientContext?.contextType == .course {
                    Image.checkSolid
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(Text(courseName))
            .accessibilityAction(named: Text("Select", bundle: .core)) {
                let recipientContext = RecipientContext(course)
                viewModel.selectedRecipientContext = recipientContext
                viewModel.didSelect?(recipientContext)
            }
            .padding(.vertical, 16)
            separator
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let recipientContext = RecipientContext(course)
            viewModel.selectedRecipientContext = recipientContext
            viewModel.didSelect?(recipientContext)
        }
    }

    private func groupRow(_ group: Group) -> some View {
        let groupName = group.name
        return VStack(spacing: 0) {
            HStack {
                Circle().fill(Color(group.color)).frame(width: 20, height: 20)
                    .padding(.leading, 22).padding(.trailing, 12)
                Text(groupName)
                    .font(.regular16)
                Spacer()
                if viewModel.selectedRecipientContext?.id == group.id, viewModel.selectedRecipientContext?.contextType == .group {
                    Image.checkSolid
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(Text(groupName))
            .accessibilityAction(named: Text("Select", bundle: .core)) {
                let recipientContext = RecipientContext(group)
                viewModel.selectedRecipientContext = recipientContext
                viewModel.didSelect?(recipientContext)
            }
            .padding(.vertical, 16)
            separator
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let recipientContext = RecipientContext(group)
            viewModel.selectedRecipientContext = recipientContext
            viewModel.didSelect?(recipientContext)
        }
    }
}

#if DEBUG

struct InboxCoursePickerView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        InboxCoursePickerAssembly.makePreview(env: env)
    }
}

#endif
