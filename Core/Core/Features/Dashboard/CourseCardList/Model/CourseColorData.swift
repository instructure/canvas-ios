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

import UIKit

public extension CourseColorData {
    static let all: [CourseColorData] = [
        .init(persistentId: "plum", color: .course1, name: String(localized: "Plum", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "fuchsia", color: .course2, name: String(localized: "Fuchsia", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "violet", color: .course3, name: String(localized: "Violet", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "ocean", color: .course4, name: String(localized: "Ocean", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "sky", color: .course5, name: String(localized: "Sky", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "sea", color: .course6, name: String(localized: "Sea", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "aurora", color: .course7, name: String(localized: "Aurora", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "forest", color: .course8, name: String(localized: "Forest", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "honey", color: .course9, name: String(localized: "Honey", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "copper", color: .course10, name: String(localized: "Copper", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "rose", color: .course11, name: String(localized: "Rose", bundle: .core, comment: "This is a name of a color.")),
        .init(persistentId: "stone", color: .course12, name: String(localized: "Stone", bundle: .core, comment: "This is a name of a color."))
    ]
}

public struct CourseColorData: Identifiable {
    public let persistentId: String
    public let color: UIColor
    public let name: String

    public var id: String { persistentId }

    public init(persistentId: String, color: UIColor, name: String) {
        self.persistentId = persistentId
        self.color = color
        self.name = name
    }
}
