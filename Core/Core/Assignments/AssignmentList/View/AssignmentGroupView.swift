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

    @ObservedObject private var viewModel: AssignmentGroupViewModel

    public init(viewModel: AssignmentGroupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Section(header: ListSectionHeader { Text(viewModel.name) }) {
            ForEach(viewModel.assignments, id: \.id) { assignment in
                let assignmentCellViewModel = AssignmentCellViewModel(assignment: assignment, courseColor: viewModel.courseColor)
                VStack(spacing: 0) {
                    AssignmentCellView(viewModel: assignmentCellViewModel)

                    if viewModel.assignments.last != assignment {
                        Divider()
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
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
