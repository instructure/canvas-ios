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

struct RedesignedRubricRatingView: View {
    @ObservedObject var viewModel: RedesignedRubricRatingViewModel

    var body: some View {
        let value = Text(viewModel.value)
        RubricSquare(isOn: $viewModel.isSelected) {
            value
        }
        .accessibility(value: value)
        .accessibility(label: Text(viewModel.accessibilityLabel))
    }
}
