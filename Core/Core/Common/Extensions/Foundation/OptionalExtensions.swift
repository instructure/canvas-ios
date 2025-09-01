//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

extension Optional {

    public func unwrapOrThrow() throws -> Wrapped {
        guard let unwrapped = self else {
            throw NSError.instructureError("Optional value was nil")
        }
        return unwrapped
    }
}

public extension Optional where Wrapped == String {
    var orEmpty: String { self ?? "" }
}

public extension Optional where Wrapped == Int {
    var orZero: Int { self ?? 0 }
}

public extension Optional where Wrapped == Double {
    var orZero: Double { self ?? 0.0 }
}

public extension Optional where Wrapped == Bool {
    var orFalse: Bool { self ?? false }
}

public extension Optional where Wrapped == Bool {
    var orTrue: Bool { self ?? true }
}
