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
import Core
import CanvasKeymaster

extension CKIClient {
    var keychainEntry: KeychainEntry? {
        guard let baseURL = baseURL else {
            return nil
        }
        return KeychainEntry(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: nil,
            locale: effectiveLocale,
            masquerader: originalIDOfMasqueradingUser.flatMap {
                (originalBaseURL ?? baseURL).appendingPathComponent("users").appendingPathComponent($0)
            },
            refreshToken: nil,
            userAvatarURL: currentUser.avatarURL,
            userID: currentUser.id,
            userName: currentUser.name,
            userEmail: currentUser.email
        )
    }
}
