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

public struct AssignmentGroupView: View {
    @Environment(\.appEnvironment) var env

    @State private var isExpanded: Bool = true
    @ObservedObject private var viewModel: AssignmentGroupViewModel

    public init(viewModel: AssignmentGroupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Section(header: ListSectionHeaderOld(backgroundColor: .backgroundLightest) { headerView() }) {
            if isExpanded {
                ForEach(viewModel.assignments, id: \.id) { assignment in
                    let assignmentCellViewModel = AssignmentCellViewModel(env: env, assignment: assignment, courseColor: viewModel.courseColor)
                    VStack(spacing: 0) {
                        AssignmentCellView(viewModel: assignmentCellViewModel)

                        InstUI.Divider()
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }

    private func headerView() -> some View {
        Button {
            isExpanded.toggle()
        } label: {
            Text(viewModel.name)
            Spacer()
            Image.arrowOpenUpLine
                .size(16)
                .rotationEffect(isExpanded ? .degrees(0) : .degrees(180))
                .accessibilityHidden(true)
                .animation(.smooth, value: isExpanded)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityHint(
            isExpanded
                ? String(localized: "Expanded", bundle: .core)
                : String(localized: "Collapsed", bundle: .core)
        )
        .padding(.vertical, 8)
    }
}

#if DEBUG

struct AssignmentGroupView_Previews: PreviewProvider {

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = UITableView.setupDefaultSectionHeaderTopPadding()

        List {
            AssignmentGroupView(viewModel: AssignmentGroupViewModel(name: "Assignment Group 1", id: "1", assignments: [], courseColor: .red))
        }
        .listStyle(PlainListStyle())
    }
}

#endif
