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
import WidgetKit

struct GradeItemView: View {
    var body: some View {
        Link(destination: item.route) {
            HStack {
                Text(item.name).lineLimit(2).font(.bold17).foregroundColor(item.color)
                Spacer()
                Text(item.grade).font(.semibold16).foregroundColor(.textDarkest)
            }.fixedSize(horizontal: false, vertical: true)
        }
    }

    private let item: GradeItem

    init(item: GradeItem) {
        self.item = item
    }
}

#if DEBUG
struct GradeItemViewPreview: PreviewProvider {
    static var previews: some View {
        GradeItemView(item: GradeItem(name: "Long Test Assignment Name To Test Line Break", grade: "80 / 100", color: .textInfo)).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
