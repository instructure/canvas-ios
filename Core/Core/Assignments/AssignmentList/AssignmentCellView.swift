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
                env.router.route(to: url, from: controller)
            }
        }, label: {
            HStack {
                Image(uiImage: viewModel.icon)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(viewModel.courseColor ?? .ash))
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.name)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                    Text(viewModel.dueText)
                        .font(.medium14).foregroundColor(.textDark)
                }
                Spacer()
                Image.arrowOpenRightLine
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.ash)
            }
        })
            .buttonStyle(PlainButtonStyle())
    }
}
/*
#if DEBUG
struct AssignmentCellView_Previews: PreviewProvider {
    static var previews: some View {
        let apiAssignment = APIAssignment.make(name: "a", submission: nil)
        let assignment = Assignment.make(from:)
        AssignmentCellView(viewModel: AssignmentCellViewModel(assignment: Assignment.make(from: )
))
    }
}
#endif
*/
