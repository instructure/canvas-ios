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

struct ModuleItemOverdueView: View {
    let dueDate: String

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Image.calendarMonthLine
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.textDark)
                    .frame(width: 18, height: 18)
                let dueText = String(localized: "Due", bundle: .horizon)
                Size12RegularTextDarkTitle(title: "\(dueText) \(dueDate)")
            }

            Spacer()

            Text("OVERDUE", bundle: .horizon)
                .font(.regular12)
                .foregroundColor(Color.textDanger)
                .padding(5)
                .overlay(Capsule().stroke(Color.backgroundDanger, lineWidth: 1))
        }
    }
}

#Preview {
    ModuleItemOverdueView(dueDate: "20-03-2025")
}
