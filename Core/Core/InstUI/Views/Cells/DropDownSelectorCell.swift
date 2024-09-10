//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

extension InstUI {

    public struct DropDownSelectorCell<Label, ID, Value, Choices>: View
    where Label: View,
          ID: Hashable,
          Value: Equatable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

        public typealias DropDown = DropDownSelector<ID, Value, Choices>

        private let label: Label
        private let selector: () -> DropDown

        public init(label: Label, selector: @escaping () -> DropDown) {
            self.label = label
            self.selector = selector
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    label.textStyle(.cellLabel)
                    Spacer()
                    selector()
                }
                .paddingStyle(set: .standardCell)
                InstUI.Divider()
            }
        }
    }
}

#if DEBUG

#Preview {
    InstUI.DropDownSelectorCell(
        label: Text(verbatim: "End")) {
            DropDownSelector(choices: [1, 2, 3, 4], id: \.self, title: \.description, selection: .constant(3))
        }
}

#endif
