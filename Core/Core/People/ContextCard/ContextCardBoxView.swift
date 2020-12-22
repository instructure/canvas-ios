//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct ContextCardBoxView: View {
    let title: String
    let subTitle: String
    let selectedColor: Color?

    init(title: String, subTitle: String, selectedColor: Color? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.selectedColor = selectedColor
    }

    var body: some View {
        VStack() {
            Text(title)
                .font(.bold20)
            Text(subTitle)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .font(.semibold12)
        }
        .foregroundColor(selectedColor != nil ? .textLight : .textDarkest)
        .padding(.horizontal, 8).padding(.vertical, 12)
        .frame(height: 80.0)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(selectedColor ?? .backgroundLight))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
struct ContextCardBoxView_Previews: PreviewProvider {
    static var previews: some View {
        HStack() {
        ContextCardBoxView(title: "56,5%", subTitle: "Grade before posting", selectedColor: .blue)
        ContextCardBoxView(title: "86,5%", subTitle: "Grade after posting")
        ContextCardBoxView(title: "86,5%", subTitle: "Grade override")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
