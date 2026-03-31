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

import Core
import Foundation

struct HelpModel: Identifiable, Equatable {
    let id: String
    let title: String
    let url: URL?
    let isBugReport: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        url: URL?,
        isBugReport: Bool
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.isBugReport = isBugReport
    }

    init(entity: CDCareerHelp) {
        self.id = entity.id
        self.title = entity.title
        self.isBugReport = entity.isBugReport
        self.url = entity.url
    }
}
