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

struct GradeListFilterButton: View {
    @Environment(\.viewController) var viewController
    @ObservedObject var viewModel: GradeListViewModel

    var body: some View {
        if viewModel.state != .initialLoading {
            Button {
                viewModel.navigateToFilter(viewController: viewController)
            } label: {
                if #available(iOS 26, *) {
                    Image.filterLine
                        .size(24)
                        .offset(y: 2)
                } else {
                    Image.filterLine
                        .size(24)
                        .padding(5)
                        .foregroundStyle(viewModel.isParentApp
                                         ? Color(Brand.shared.primary)
                                         : .textLightest)
                }
            }
            .accessibilityLabel(Text("Filter", bundle: .core))
            .accessibilityHint(Text("Filter grades options", bundle: .core))
            .accessibilityIdentifier("GradeList.filterButton")
        }
    }
}
