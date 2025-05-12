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

struct SubmissionListView: View {

    @Environment(\.viewController) private var controller

    @StateObject private var viewModel: SubmissionListViewModel
    @State private var isFilterSelectorPresented: Bool = false

    init(viewModel: SubmissionListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView().progressViewStyle(.indeterminateCircle())
            case .data, .empty:
                listView
            case .error:
                Text("Error loading data")
            }
        }
        .navigationTitle(Text("Submissions", bundle: .teacher))
        .navigationBarStyle(.color(viewModel.course?.color))
    }

    private var listView: some View {
        List {

            Section {
                HeaderView(courseName: viewModel.assignment?.name ?? "")
            }

            if viewModel.state == .data {

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
            } else {
                Text("No submissions!")
                    .font(.regular14)
                    .foregroundStyle(Color.textDark)
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.backgroundLight)
                    .listRowSeparator(.hidden)
            }
        }
        .listSectionSpacing(0)
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .background(Color.backgroundLight)
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar {

            ToolbarItemGroup(placement: .topBarTrailing) {

                Button {
                    isFilterSelectorPresented = true
                } label: {
                    viewModel.filterMode == .all ? Image.filterLine : Image.filterSolid
                }
                .tint(Color.textLightest)

                Button {
                    viewModel.openPostPolicy(from: controller)
                } label: {
                    Image.eyeLine
                }
                .tint(Color.textLightest)
                .accessibilityIdentifier("SubmissionsList.postPolicyButton")

                Button {
                    viewModel.messageUsers(from: controller)
                } label: {
                    Image.emailLine
                }
                .tint(Color.textLightest)
            }
        }
        .sheet(isPresented: $isFilterSelectorPresented) {
            SubmissionsFilterView(viewModel: viewModel)
        }
    }

    private var anonymizeStudents: Bool {
        viewModel.assignment?.anonymizeStudents ?? false
    }
}

private extension SubmissionListView {

    struct SeparatedRow<Content: View>: View {
        @ViewBuilder let content: () -> Content
        var body: some View {
            VStack(spacing: 0) {
                content()
                Divider()
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
                    Image.searchLine.size(uiScale.iconScale * 16).foregroundStyle(Color.textDark)
                    TextField("Search Submissions", text: $viewModel.searchText, prompt: Text("Search"))
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

extension EdgeInsets {
    static var zero: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
