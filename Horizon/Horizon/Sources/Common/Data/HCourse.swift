//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct HCourse {
    let id: String
    let name: String
    let imageURL: URL?

    init(id: String, name: String, imageURL: URL?) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }

    init(from entity: Course) {
        self.id = entity.id
        self.name = entity.name ?? ""
        self.imageURL = entity.imageDownloadURL
    }
}
