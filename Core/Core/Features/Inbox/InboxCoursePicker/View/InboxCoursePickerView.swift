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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                courses(favorites: viewModel.favoriteCourses, more: viewModel.moreCourses)
                groups(viewModel.groups)
            }
        case .empty, .error:
            Text("Some error occured", bundle: .core)
                .font(.regular17)
                .foregroundColor(.textDarkest)
        }
    }

    private func courses(favorites: [Course], more: [Course]) -> some View {
        VStack(spacing: 0) {
            switch (favorites.isNotEmpty, more.isNotEmpty) {
            case (true, true):
                courseSection(with: favorites, title: String(localized: "Favorite Courses", bundle: .core))
                courseSection(with: more, title: String(localized: "More Courses", bundle: .core))
            case (true, false):
                courseSection(with: favorites, title: String(localized: "Courses", bundle: .core))
            case (false, true):
                courseSection(with: more, title: String(localized: "Courses", bundle: .core))
            case (false, false):
                SwiftUI.EmptyView()
            }
        }
    }

    private func courseSection(with courses: [Course], title: String) -> some View {
        VStack(spacing: 0) {
            Section {
                ForEach(courses, id: \.id) { courseRow($0) }
            } header: {
                InstUI.ListSectionHeader(title: title)
            }
        }
    }

    private func groups(_ groups: [Group]) -> some View {
        VStack(spacing: 0) {
            if groups.isNotEmpty {
                Section {
                    ForEach(groups, id: \.id) { group in
                        groupRow(group)
                    }
                } header: {
                    VStack(spacing: 0) {
                        InstUI.ListSectionHeader(title: String(localized: "Groups", bundle: .core))
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
                    Circle()
                        .fill(Color(course.color))
                        .frame(width: 20, height: 20)
                        .padding(.leading, 22)
                        .padding(.trailing, 12)
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

            InstUI.Divider()
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
                    Circle()
                        .fill(Color(group.color))
                        .frame(width: 20, height: 20)
                        .padding(.leading, 22)
                        .padding(.trailing, 12)
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

            InstUI.Divider()
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
