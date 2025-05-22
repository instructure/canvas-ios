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
import Core

struct SubmissionListScreen: View {

    @Environment(\.viewController) private var controller
    @Environment(\.appEnvironment) private var env

    @StateObject private var viewModel: SubmissionListViewModel

    init(viewModel: SubmissionListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: { completion in
                viewModel.refresh(completion)
            },
            content: { _ in listView }
        )
        .toolbar(content: { toolbarContent })
        .navigationTitle(Text("Submissions", bundle: .teacher))
        .navigationBarStyle(.color(viewModel.course?.color))
    }

    private var listView: some View {
        LazyVStack {
            Section {
                HeaderView(courseName: viewModel.assignment?.name ?? "")
            }
            if anonymizeStudents == false {
                Section {
                    SearchView(viewModel: viewModel)
                }
            }
            ForEach($viewModel.sections) { $section in
                Section {
                    if !section.isCollapsed {
                        ForEach(section.items) { item in
                            SeparatedRow {
                                Button(
                                    action: {
                                        viewModel.didTapSubmissionRow(item, from: controller)
                                    },
                                    label: {
                                        SubmissionListRowView(
                                            anonymizeStudents: anonymizeStudents,
                                            item: item
                                        )
                                    }
                                )
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(title: section.kind.title, isCollapsed: $section.isCollapsed)
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItemGroup(placement: .topBarTrailing) {

            InstUI
                .NavigationBarButton
                .filterIcon(
                    isBackgroundContextColor: true,
                    isSolid: viewModel.filterMode != .all,
                    action: {
                        viewModel.showFilterScreen(from: controller)
                    }
                )
                .tint(Color.textLightest)

            Button {
                viewModel.openPostPolicy(from: controller)
            } label: {
                Image.eyeLine
            }
            .tint(Color.textLightest)
            .accessibilityLabel(Text("Post settings", bundle: .teacher))
            .accessibilityIdentifier("SubmissionsList.postPolicyButton")

            Button {
                viewModel.messageUsers(from: controller)
            } label: {
                Image.emailLine
            }
            .tint(Color.textLightest)
            .accessibility(label: Text("Send message to users", bundle: .teacher))
        }
    }

    private var anonymizeStudents: Bool {
        viewModel.assignment?.anonymizeStudents ?? false
    }
}

private extension SubmissionListScreen {

    struct SeparatedRow<Content: View>: View {
        @ScaledMetric private var uiScale: CGFloat = 1
        @ViewBuilder let content: () -> Content

        var body: some View {
            VStack(spacing: 0) {
                content()
                InstUI.Divider()
                Spacer().frame(height: 0.5)
            }
            .listRowInsets(.zero)
            .listRowSeparator(.hidden)
        }
    }

    struct SearchView: View {

        @ObservedObject private var viewModel: SubmissionListViewModel
        @ScaledMetric private var uiScale: CGFloat = 1

        init(viewModel: SubmissionListViewModel) {
            self.viewModel = viewModel
        }

        var body: some View {
            SeparatedRow {
                HStack(spacing: 9) {
                    Image
                        .searchLine
                        .size(uiScale.iconScale * 16)
                        .foregroundStyle(Color.textDark)
                        .accessibilityHidden(true)
                    TextField(
                        String(localized: "Search Submissions", bundle: .teacher),
                        text: $viewModel.searchText, prompt: Text("Search", bundle: .teacher))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.regular14)
                        .foregroundStyle(Color.textDarkest)
                    Spacer()
                }
                .padding(8)
                .background(Color.backgroundLight, in: RoundedRectangle(cornerRadius: 10))
                .padding(16)
                .background(Color.backgroundLightest)
            }
        }
    }

    struct HeaderView: View {

        @ScaledMetric private var uiScale: CGFloat = 1
        let courseName: String

        var body: some View {
            SeparatedRow {
                HStack {
                    Text(courseName)
                        .foregroundStyle(Color.textDarkest)
                        .font(.semibold16)

                    Spacer()
                }
                .padding(16)
                .background(
                    Color.backgroundLightest,
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 2)
                .padding(16)
                .background(Color.backgroundLight)
            }
        }
    }

    struct SectionHeaderView: View {
        let title: String
        @Binding var isCollapsed: Bool

        @ScaledMetric private var uiScale: CGFloat = 1

        var body: some View {
            SeparatedRow {
                Button(action: {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }) {
                    HStack {
                        Text(title)
                            .font(.semibold14)
                            .foregroundStyle(Color.textDark)
                        Spacer()
                        Image
                            .arrowOpenDownLine
                            .size(uiScale.iconScale * 16)
                            .foregroundColor(.textDarkest)
                            .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.backgroundLightest)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
