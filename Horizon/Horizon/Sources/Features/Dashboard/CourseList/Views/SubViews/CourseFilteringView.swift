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

import HorizonUI
import SwiftUI

struct OptionModel: Identifiable, Equatable {
    let id: String
    let name: String
}

struct FilterView: View {

     // MARK: - Dependencies

     private let items: [OptionModel]
     private let selectedOption: OptionModel?
     private let onSelect: (OptionModel?) -> Void

     // MARK: - Init

     init(
         items: [OptionModel],
         selectedOption: OptionModel?,
         onSelect: @escaping (OptionModel?) -> Void
     ) {
         self.items = items
         self.selectedOption = selectedOption
         self.onSelect = onSelect
     }

     var body: some View {
         Menu {
             ForEach(items) { item in
                 Button {
                     onSelect(item)
                 } label: {
                     HStack {
                         if item == selectedOption {
                             Image.huiIcons.check
                                 .frame(width: 24, height: 24)
                         }
                         Text(item.name)
                     }
                 }
                 .accessibilityAddTraits(item == selectedOption ? .isSelected : [])
                 .accessibilityRemoveTraits(.isButton)
             }
         } label: {
             CourseSelectionButton(
                status: selectedOption?.name ?? ""
             ) { }
                 .accessibilityRemoveTraits(.isButton)
         }
         .accessibilityRemoveTraits(.isButton)
         .accessibilityHint(
            Text(
                String.localizedStringWithFormat(
                    String(localized: "Selected filter is %@. Double tap to select another filter.", bundle: .horizon),
                    selectedOption?.name ?? "",
                )
            )
         )
     }
}
