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

private var sessionAssociationKey: UInt8 = 0

extension CKIUser {
    func sessionUser() -> SessionUser {
        return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
    }
}

extension CKIClient {
    public var authSession: Session {
        if let session = objc_getAssociatedObject(self, &sessionAssociationKey) as? Session {
            return session
        }
        
        let url = baseURL ?? URL(string: "")!
        var masqueradeID: String? = nil
        if let actAsUserID = actAsUserID, actAsUserID.count > 0 { masqueradeID = actAsUserID }
        let session = Session(baseURL: url, user: currentUser.sessionUser(), token: accessToken, masqueradeAsUserID: masqueradeID)
        objc_setAssociatedObject(self, &sessionAssociationKey, session, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return session
    }
}
