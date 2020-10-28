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

struct NoGradesView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text(NSLocalizedString("No Grades To Display", comment: ""))
                .font(.semibold12)
                .foregroundColor(.textDark)
        }.padding()
    }
}

#if DEBUG
struct NoGradesViewPreviews: PreviewProvider {
    static var previews: some View {
        NoGradesView().previewContext(WidgetPreviewContext(family: .systemSmall))
        NoGradesView().previewContext(WidgetPreviewContext(family: .systemMedium))
        NoGradesView().previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
