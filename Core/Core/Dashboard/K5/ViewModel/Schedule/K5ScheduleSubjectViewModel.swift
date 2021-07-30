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

public class K5ScheduleSubjectViewModel {
    public let name: String
    public let color: Color
    public let image: Image?
    public let entries: [K5ScheduleEntryViewModel]
    public var hasTapAction: Bool { tapAction != nil }

    private let tapAction: (() -> Void)?

    public init(name: String, color: Color, image: Image?, entries: [K5ScheduleEntryViewModel], tapAction: (() -> Void)?) {
        self.name = name
        self.color = color
        self.image = image
        self.entries = entries
        self.tapAction = tapAction
    }

    public func viewTapped() {
        tapAction?()
    }
}
