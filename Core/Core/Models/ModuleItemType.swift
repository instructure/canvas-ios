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

public enum ModuleItemType: Equatable {
    case file(String)
    case discussion(String)
    case assignment(String)
    case quiz(String)
    case externalURL(URL)
    case externalTool(String, URL)
    case page(String)
    case subHeader

    public static func == (lhs: ModuleItemType, rhs: ModuleItemType) -> Bool {
        switch (lhs, rhs) {
        case let (.file(lhs), .file(rhs)):
            return lhs == rhs
        case let (.discussion(lhs), .discussion(rhs)):
            return lhs == rhs
        case let (.assignment(lhs), .assignment(rhs)):
            return lhs == rhs
        case let (.quiz(lhs), .quiz(rhs)):
            return lhs == rhs
        case let (.externalURL(lhs), .externalURL(rhs)):
            return lhs == rhs
        case let (.externalTool(lhsID, lhsURL), .externalTool(rhsID, rhsURL)):
            return lhsID == rhsID && lhsURL == rhsURL
        case let (.page(lhs), .page(rhs)):
            return lhs == rhs
        case (.subHeader, .subHeader):
            return true
        default:
            return false
        }
    }
}
