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

import UIKit

public protocol LoginDelegate: AnyObject {
    var supportsCanvasNetwork: Bool { get }
    var helpURL: URL? { get }
    var whatsNewURL: URL? { get }
    var findSchoolButtonTitle: String { get }

    func openExternalURL(_ url: URL)
    func openExternalURLinSafari(_ url: URL)
    func userDidLogin(session: LoginSession)
    func userDidStartActing(as session: LoginSession)
    func userDidStopActing(as session: LoginSession)
    func userDidLogout(session: LoginSession)
    func changeUser()
    func actAsStudentViewStudent(studentViewStudent: APIUser)
}

public extension LoginDelegate {
    var supportsCanvasNetwork: Bool { true }
    var helpURL: URL? { URL(string: "https://community.canvaslms.com/docs/DOC-1543") }
    var whatsNewURL: URL? { nil }
    var findSchoolButtonTitle: String { NSLocalizedString("Find my school", bundle: .core, comment: "") }

    func changeUser() {}
    func openExternalURLinSafari(_ url: URL) {}

    func userDidStartActing(as session: LoginSession) {
        userDidLogin(session: session)
    }
    func userDidStopActing(as session: LoginSession) {
        userDidLogout(session: session)
    }

    func startActing(as session: LoginSession) {
        userDidStartActing(as: session)
    }

    func stopActing(as session: LoginSession, findOriginalFrom entries: Set<LoginSession> = LoginSession.sessions) {
        guard let baseURL = session.originalBaseURL, let userID = session.originalUserID else { return }
        if let original = entries.first(where: { $0.baseURL == baseURL && $0.userID == userID && $0.masquerader == nil }) {
            userDidStopActing(as: session)
            userDidLogin(session: original.bumpLastUsedAt())
        } else if session.isFakeStudent {
            userDidStopActing(as: session)
            changeUser()
        } else {
            userDidLogout(session: session)
        }
    }

    func actAsStudentViewStudent(studentViewStudent: APIUser) {}
}
