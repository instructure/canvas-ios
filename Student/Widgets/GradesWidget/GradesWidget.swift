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

struct GradesWidget: Widget {
    let kind: String = "GradesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GradesWidgetProvider()) { model in
            GradesWidgetView(model: model)
        }
        .configurationDisplayName(NSLocalizedString("Grades", comment: "Name of the grades widget"))
        .description(NSLocalizedString("View the latest grades from assignments and your favorite courses.", comment: "Description of the grades widget"))
        .contentMarginsDisabled()
    }
}
