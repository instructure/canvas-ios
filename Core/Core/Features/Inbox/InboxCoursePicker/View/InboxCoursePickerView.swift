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
        ScrollView {
            let title = viewModel.groups.isEmpty
                ? String(localized: "Select a Course", bundle: .core)
                : String(localized: "Select a Course or a Group", bundle: .core)
            content
                .navigationBarTitleView(title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarStyle(.modal)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .font(.regular12)
        .foregroundColor(.textDarkest)
        .frame(maxWidth: .infinity)
        .navigationBarStyle(.modal)
        .background(Color.backgroundLightest)
    }

    @ViewBuilder
    private var content: some View {
            switch viewModel.state {
            case .loading:
                VStack {
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle())
                        .padding(12)
                }
            case .data:
                VStack(spacing: 0) {
                    courses(courses: viewModel.courses)
                    groups(groups: viewModel.groups)
                }
            case .empty, .error:
                Text("Some error occured", bundle: .core)
                    .font(.regular17)
                    .foregroundColor(.textDarkest)
            }
        }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private func courses(courses: [Course]) -> some View {
        VStack(spacing: 0) {
            if !courses.isEmpty {
                Section(header:
                        VStack(spacing: 0) {
                    Text("Courses", bundle: .core)
                        .font(.regular14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.textDarkest)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .background(Color.backgroundLight)
                        .accessibilityHeading(.h1)
                    separator
                    }
                ) {
                    ForEach(courses, id: \.id) { course in
                        courseRow(course)
                    }
                }
            }
        }
    }

    private func groups(groups: [Group]) -> some View {
        VStack(spacing: 0) {
            if !groups.isEmpty {
                Section(header:
                    VStack(spacing: 0) {
                    Text("Groups", bundle: .core)
                        .font(.regular14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.textDarkest)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .background(Color.backgroundLight)
                        .accessibilityHeading(.h1)
                    separator
                    }
                ) {
                    VStack(spacing: 0) {
                        ForEach(groups, id: \.id) { group in
                            groupRow(group)
                        }
                    }
                }
            }
        }
    }

    private func isSelected(_ course: Course) -> Bool {
        return viewModel.selectedRecipientContext?.context.id == course.id && viewModel.selectedRecipientContext?.context.contextType == .course
    }

    private func isSelected(_ group: Group) -> Bool {
        viewModel.selectedRecipientContext?.context.id == group.id && viewModel.selectedRecipientContext?.context.contextType == .group
    }

    private func courseRow(_ course: Course) -> some View {
        let courseName = course.name ?? course.courseCode ?? ""
        let accessibilityLabel = isSelected(course) ? Text("Selected: \(courseName)", bundle: .core) : Text(courseName)
        return VStack(spacing: 0) {
            Button {
                viewModel.onSelect(selected: course)
            } label: {
                HStack {
                    Circle().fill(Color(course.color)).frame(width: 20, height: 20)
                        .padding(.leading, 22).padding(.trailing, 12)
                    Text(courseName)
                        .font(.regular16)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image.checkSolid
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .hidden(!isSelected(course))

                }
                .foregroundStyle(Color.textDarkest)
            }
            .padding(.vertical, 16)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier("Inbox.course.\(course.id)")

            separator
        }
    }

    private func groupRow(_ group: Group) -> some View {
        let groupName = group.name
        let accessibilityLabel = isSelected(group) ? Text("Selected: \(groupName)", bundle: .core) : Text(groupName)
        return VStack(spacing: 0) {
            Button {
                viewModel.onSelect(selected: group)
            } label: {
                HStack {
                    Circle().fill(Color(group.color)).frame(width: 20, height: 20)
                        .padding(.leading, 22).padding(.trailing, 12)
                    Text(groupName)
                        .font(.regular16)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image.checkSolid
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .hidden(!isSelected(group))
                }
                .foregroundStyle(Color.textDarkest)
            }
            .padding(.vertical, 16)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier("Inbox.group.\(group.id)")

            separator
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
