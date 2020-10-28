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

struct MediumLargeGradesView : View {
    var body: some View {
        VStack {
            HeaderView(title: NSLocalizedString("Grades", comment: ""))
            ForEach(items.prefix(lineCount), id: \.self) { gradeItem in
                GradeItemView(item: gradeItem).padding(.top)
            }
            Spacer()
        }.padding()
    }

    private let items: [GradeItem]
    private let lineCount: Int

    init(items: [GradeItem], lineCount: Int) {
        self.items = items
        self.lineCount = lineCount
    }
}

#if DEBUG
struct MediumLargeGradesViewPreview: PreviewProvider {
    static var previews: some View {
        let items = GradeModel.make().items
        MediumLargeGradesView(items: items, lineCount: 2).previewContext(WidgetPreviewContext(family: .systemMedium))
        MediumLargeGradesView(items: items, lineCount: 6).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
