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

public struct AssignmentListView: View {

    @ObservedObject private var viewModel: AssignmentListViewModel

    public init(viewModel: AssignmentListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            HStack {
                Text("Grading period Title").font(.bold20)
                Spacer(minLength: 8)
                Button(action:{}, label: {Text("Filter")})
            }.padding(16)
            List {
                Section(header: Text("Assignments")) {
                    assignmentCell
                }
            }
        }
    }

    @ViewBuilder var assignmentGroup: some View {
        Text("YOLO")
    }

    @ViewBuilder var assignmentCell: some View {
        Button(action: {}, label: {
            HStack {
                Image.assignmentLine
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.ash)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Assignment Title")
                    .font(.bold17)
                    Text("Details")
                }
                Image.arrowOpenRightLine
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.ash)
            }
        })
    }
}

#if DEBUG
struct AssignmentListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AssignmentListViewModel()
        AssignmentListView(viewModel: viewModel)
    }
}
#endif
