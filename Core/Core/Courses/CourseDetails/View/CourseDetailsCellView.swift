//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct CourseDetailsCellView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: CourseDetailsCellViewModel

    public init(viewModel: CourseDetailsCellViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button(action: {
            if let url = viewModel.route {
                    env.router.route(to: url, from: controller)
                }
        }, label: {
            HStack(spacing: 13) {
                Image(uiImage: viewModel.iconImage)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(viewModel.courseColor ?? .ash))
                    .padding(.top, 2)
                    .frame(maxHeight: .infinity, alignment: .top)
                Text(viewModel.label)
                Spacer()
                InstDisclosureIndicator()
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
        // TODO
        .accessibility(identifier: "assignment-list.assignment-list-row.cell-\(viewModel.id)")
    }
}

#if DEBUG
/*
struct CourseDetailsCellView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDetailsCellView()
    }
}
*/
#endif
