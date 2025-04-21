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

    @ObservedObject private var viewModel: SubmissionListViewModel

    init(viewModel: SubmissionListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .initialLoading, .empty:
            ProgressView()
        case .data:
            listView
        case .error:
            Text("Error loading data")
        }
    }

    private var listView: some View {
        List {
            ForEach($viewModel.sections) { $section in
                Section {
                    if !section.isCollapsed {
                        ForEach(section.submissions) { submission in
                            VStack(spacing: 0) {
                                SubmissionListRowView(
                                    submission: submission,
                                    assignment: viewModel.assignment
                                )
                                Divider()
                            }
                            .listRowInsets(.zero)
                            .listRowSeparator(.hidden)
                        }
                    }
                } header: {
                    VStack(spacing: 0) {
                        SectionHeaderView(title: section.title, isCollapsed: $section.isCollapsed)
                        Divider()
                    }
                        .listRowInsets(.zero)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listSectionSpacing(0)
        .listStyle(.plain)
    }
}

struct SectionHeaderView: View {
    let title: String
    @Binding var isCollapsed: Bool

    var body: some View {
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
                Image(systemName: "chevron.forward")
                    .foregroundColor(.textDarkest)
                    .rotationEffect(isCollapsed ? .degrees(0) : .degrees(90))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
        }
        .buttonStyle(.borderless)
    }
}

extension EdgeInsets {
    static var zero: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
