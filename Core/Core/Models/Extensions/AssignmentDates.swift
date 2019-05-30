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

//  Only assignment dates related content here

extension Assignment {
    public func isOpenForSubmissions(referenceDate: Date = Clock.now) -> Bool {
        var open = !lockedForUser

        if let lockAt = lockAt {
            open = open && lockAt > referenceDate
        }

        if let unlockAt = unlockAt {
            open = open && referenceDate >= unlockAt
        }
        return open
    }
}
