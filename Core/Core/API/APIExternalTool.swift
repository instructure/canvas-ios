//
// Copyright (C) 2018-present Instructure, Inc.
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

public struct APIExternalTool: Codable, Equatable {
    public let id: ID
    public let name: String
    public let domain: String?
    public let url: URL

    public var arc: Bool {
        return domain?.contains("arc.instructure.com") == true
    }
}

public struct APIGetSessionlessLaunchResponse: Codable, Equatable {
    public let url: URL
}
