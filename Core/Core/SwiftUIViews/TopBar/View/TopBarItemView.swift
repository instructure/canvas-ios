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

public struct TopBarItemView: View {
    @ObservedObject private var viewModel: TopBarItemViewModel
    private let selectAction: () -> Void

    public init(viewModel: TopBarItemViewModel, selectAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.selectAction = selectAction
    }

    public var body: some View {
        Button(action: selectAction) {
            HStack(spacing: 9) {
                viewModel.icon
                    .frame(width: 20, height: 20)
                viewModel.label
                    .font(.regular14)
            }
            .accentColor(viewModel.isSelected ? Color(Brand.shared.primary) : .oxford)
            .padding(.vertical, 14)
        }
        .accessibility(addTraits: viewModel.isSelected ? .isSelected : [])
    }
}

#if DEBUG

struct TopBarItemView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarItemView(viewModel: TopBarItemViewModel(id: "1", icon: .k5homeroom, label: Text(verbatim: "Menu Item")), selectAction: {})
            .previewLayout(.sizeThatFits)
    }
}

#endif
