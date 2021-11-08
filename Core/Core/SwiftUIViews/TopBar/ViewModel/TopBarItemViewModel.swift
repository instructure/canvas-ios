//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class TopBarItemViewModel: ObservableObject {
    public var icon: Image?
    public var label: Text
    public var id: String?
    @Published public var isSelected = false

    public init(icon: Image, label: Text) {
        self.icon = icon
        self.label = label
    }

    public init(tab: Tab, iconImage: Image?) {
        self.label = Text(tab.label)
        self.id = tab.id
        self.icon = iconImage
    }
}
