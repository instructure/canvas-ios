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

public struct ParentInboxCoursePickerView: View {
    @ObservedObject private var viewModel: ParentInboxCoursePickerViewModel

    init(viewModel: ParentInboxCoursePickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a course to message")
                    .font(.regular16)
                    .foregroundColor(.textDark)

                ForEach(viewModel.items, id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.course.name ?? "")
                                .font(.regular16)
                                .foregroundColor(.textDarkest)
                                .background(.white)

                            Text(item.studentDisplayName)
                                .font(.regular14)
                                .foregroundColor(.textDark)

                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 12)
        }
    }
}

#Preview {
    //ParentInboxCoursePickerView()
}
