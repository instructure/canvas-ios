//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core

extension ModuleItem: Fixture {
    public static let template: Template = [
        "id": "1",
        "title": "Module Item 1",
        "position": 1,
        "published": true,
        "moduleID": "1",
        "indent": 0,
        "htmlURL": URL(string: "https://canvas.example.edu/courses/222/modules/items/768")!,
        "url": URL(string: "https://canvas.example.edu/api/v1/courses/222/assignments/987")!,
        "type": ModuleItemType.assignment("1").data,
    ]
}

extension ModuleItemType {
    public var data: Data {
        return try! JSONEncoder().encode(self)
    }
}
