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

struct WeekDaysSelectionListView: View {

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var selection: [Weekday]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Weekday.allCases, id: \.rawValue) { weekDay in
                    let isSelected = selection.contains(weekDay)

                    Button(
                        action: {
                            selection.appendOrRemove(weekDay)
                        },
                        label: {
                            HStack {
                                Text(weekDay.text)
                                    .textStyle(.dropDownOption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                InstUI.Icons.Checkmark()
                                    .foregroundStyle(Color.textDarkest)
                                    .layoutPriority(1)
                                    .hidden(isSelected == false)
                            }
                            .paddingStyle(set: .standardCell)
                            .contentShape(Rectangle())
                        })
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])

                    if Weekday.allCases.last != weekDay {
                        InstUI.Divider()
                    }
                }
            }
            .frame(minWidth: 260)
            .fixedSize()
            .preferredAsDropDownDetails()
        }
        .onTapGesture { } // Fixes an issue with tappable area of first and last buttons.
    }
}

#Preview {
    WeekDaysSelectionListView(selection: .constant([]))
}
