//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public extension Array where Element == CourseSyncEntry {
    var totalSelectedSize: Int {
        reduce(0) { partialResult, entry in
            partialResult + entry.totalSelectedSize
        }
    }

    var totalDownloadedSize: Int {
        reduce(0) { partialResult, entry in
            partialResult + entry.totalDownloadedSize
        }
    }

    var progress: Float {
        guard totalSelectedSize > 0 else { return 0 }
        return Float(totalDownloadedSize) / Float(totalSelectedSize)
    }

    var hasError: Bool {
        contains { $0.hasError }
    }

    subscript(id id: String) -> CourseSyncEntry? {
        get {
            self.first(where: { $0.id == id })
        } set {
            if let firstIndex = firstIndex(where: { $0.id == id }), let newValue {
                self[firstIndex] = newValue
            }
        }
    }
}

public extension Array where Element == CourseSyncEntry.Tab {
    subscript(id id: String) -> CourseSyncEntry.Tab? {
        get {
            self.first(where: { $0.id == id })
        } set {
            if let firstIndex = firstIndex(where: { $0.id == id }), let newValue {
                self[firstIndex] = newValue
            }
        }
    }
}

public extension Array where Element == CourseSyncEntry.File {
    subscript(id id: String) -> CourseSyncEntry.File? {
        get {
            self.first(where: { $0.id == id })
        } set {
            if let firstIndex = firstIndex(where: { $0.id == id }), let newValue {
                self[firstIndex] = newValue
            }
        }
    }
}
