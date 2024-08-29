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

    @Binding var selection: [Weekday]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Weekday.allCases, id: \.rawValue) { weekDay in
                    Button(
                        action: {
                            selection.toggleInsert(with: weekDay)
                        },
                        label: {
                            HStack {
                                Text(weekDay.text)
                                    .font(.medium16)
                                    .foregroundStyle(Color.textDarkest)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                InstUI.Icons.Checkmark()
                                    .layoutPriority(1)
                                    .opacity(selection.contains(weekDay) ? 1 : 0)
                            }
                            .contentShape(Rectangle())
                        })
                    .buttonStyle(.plain)
                    .paddingStyle(.all, .dropDownOption)
                    InstUI.Divider()
                }
            }
            .frame(minWidth: 200)
            .fixedSize()
            .preferredAsDropDownDetails()
        }
    }
}

#Preview {
    WeekDaysSelectionListView(selection: .constant([]))
}
