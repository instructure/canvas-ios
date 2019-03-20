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

public class UUID {
    private static let shared = UUID()
    private var string: String?

    public static func mock(_ string: String) {
        shared.string = string
    }

    public static func reset() {
        shared.string = nil
    }

    public static var string: String {
        #if DEBUG
        if let uuid = shared.string {
            return uuid
        }
        #endif
        return Foundation.UUID().uuidString
    }
}
