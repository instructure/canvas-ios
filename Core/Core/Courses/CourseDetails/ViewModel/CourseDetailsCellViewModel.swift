//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension Tab: TabViewable {}

public class CourseDetailsCellViewModel: ObservableObject {

    private let tab: Tab
    public private(set) var courseColor: UIColor?

    public init(tab: Tab, courseColor: UIColor?) {
        self.tab = tab
        self.courseColor = courseColor
    }

    public var route: URL? {
        tab.htmlURL
    }

    public var iconImage: UIImage {
        tab.icon
    }

    public var label: String {
        tab.label
    }

    public var id: String {
        tab.id
    }

    public var isHome: Bool {
        tab.label == "Home"
    }
}

extension CourseDetailsCellViewModel: Equatable {

    public static func == (lhs: CourseDetailsCellViewModel, rhs: CourseDetailsCellViewModel) -> Bool {
        lhs.tab.id == rhs.tab.id
    }
}
