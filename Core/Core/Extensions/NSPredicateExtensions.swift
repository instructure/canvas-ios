//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

extension NSPredicate {
    public static var all: NSPredicate {
        return NSPredicate(value: true)
    }

    public static func id(_ id: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public convenience init(key: String, equals value: CVarArg?) {
        if let value = value {
            self.init(format: "%K == %@", key, value)
        } else {
            self.init(format: "%K == nil", key)
        }
    }
}
