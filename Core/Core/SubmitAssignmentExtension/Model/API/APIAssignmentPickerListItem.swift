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

public struct APIAssignmentPickerListItem: Equatable {
    public let id: String
    public let name: String
    public let allowedExtensions: [String]
    public let gradeAsGroup: Bool

    public init(id: String, name: String, allowedExtensions: [String], gradeAsGroup: Bool) {
        self.id = id
        self.name = name
        self.allowedExtensions = allowedExtensions
        self.gradeAsGroup = gradeAsGroup
    }

    public func isFileAllowed(_ url: URL) -> Bool {
        allowedExtensions.isEmpty ? true : allowedExtensions.contains(url.pathExtension)
    }
}
