//
// Copyright (C) 2016-present Instructure, Inc.
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


public protocol LockableModel: class {
    var lockedForUser: Bool { get set }
    var lockExplanation: String? { get set }
    var canView: Bool { get set }
}

import Marshal

extension LockableModel {
    public func updateLockStatus(_ json: JSONObject) throws {
        try lockedForUser = (json <| "locked_for_user") ?? false
        try lockExplanation = json <| "lock_explanation"
        try canView = (json <| "lock_info.can_view") ?? true
    }
}
