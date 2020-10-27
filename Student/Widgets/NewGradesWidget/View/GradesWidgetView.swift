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

import WidgetKit
import SwiftUI

struct GradesWidgetView : View {
    private let model: GradeModel
    @Environment(\.widgetFamily)
    private var family
    private let lineCountByFamily: [WidgetFamily: Int] = [
        .systemMedium: 2,
        .systemLarge: 6,
    ]

    var body: some View {
        switch family {
        case .systemMedium, .systemLarge:
            VStack {
                HeaderView(title: NSLocalizedString("Grades", comment: ""))
                ForEach(model.items.prefix(lineCountByFamily[family]!), id: \.self) { gradeItem in
                    GradeItemView(item: gradeItem).padding(.top)
                }
                Spacer()
            }.padding()
        default:
            VStack {
                HeaderView(title: NSLocalizedString("Grades", comment: ""))
                Spacer()
            }.padding()
        }
    }

    init(model: GradeModel) {
        self.model = model
    }
}

#if DEBUG
struct GradesWidgetPreviews: PreviewProvider {
    static var previews: some View {
        let data = GradeModel.make()
        GradesWidgetView(model: data).previewContext(WidgetPreviewContext(family: .systemSmall))
        GradesWidgetView(model: data).previewContext(WidgetPreviewContext(family: .systemMedium))
        GradesWidgetView(model: data).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
