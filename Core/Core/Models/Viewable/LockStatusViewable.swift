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

public protocol LockStatusViewable {
    var dueAt: Date? { get }
    var lockAt: Date? { get }
}

extension LockStatusViewable {
    public var lockStatusText: String? {
        guard dueAt != nil, let lockAt = lockAt, lockAt < Date() else { return nil }
        return NSLocalizedString("Closed", bundle: .core, comment: "")
    }
}
