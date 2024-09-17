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

import Foundation

public extension HTTPCookie {

#if DEBUG

    static func make(
        name: String = "testName",
        value: String = "testValue",
        path: String = "/login",
        domain: String = "instructure.com",
        version: Int = 1
    ) -> HTTPCookie {
        HTTPCookie(
            properties: [
                .name: name,
                .value: value,
                .path: path,
                .domain: domain,
                .version: 1
            ]
        )!
    }

#endif
}
