//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension LearnerDashboardColorSelectorView {
    static let colors: [ColorData] = [
        .init(color: .course1, description: String(localized: "Plum", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course2, description: String(localized: "Fuchsia", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course3, description: String(localized: "Violet", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course4, description: String(localized: "Ocean", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course5, description: String(localized: "Sky", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course6, description: String(localized: "Sea", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course7, description: String(localized: "Aurora", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course8, description: String(localized: "Forest", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course9, description: String(localized: "Honey", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course10, description: String(localized: "Copper", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course11, description: String(localized: "Rose", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .course12, description: String(localized: "Stone", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .backgroundLightest, description: String(localized: "White", bundle: .core, comment: "This is a name of a color.")),
        .init(color: .backgroundLightest.variantForDarkMode, description: String(localized: "Black", bundle: .core, comment: "This is a name of a color."))
    ]

    struct ColorData: Hashable {
        let color: Color
        let description: String
    }
}
