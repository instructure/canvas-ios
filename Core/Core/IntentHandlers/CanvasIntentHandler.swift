//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public protocol CanvasIntentHandler {
    var env: AppEnvironment { get }
    var isLoggedIn: Bool { get }

    func setupLastLoginCredentials()
}

extension CanvasIntentHandler {
    public var env: AppEnvironment {
        AppEnvironment.shared
    }

    public var isLoggedIn: Bool {
        LoginSession.mostRecent != nil
    }

    public func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session)
    }
}

extension INCourse {
    convenience init?(_ course: APICourse) {
        guard !(course.course_code ?? "").isEmpty || !(course.name ?? "").isEmpty else { return nil }
        self.init(identifier: course.id.rawValue, display: [course.course_code, course.name].compactMap({$0}).joined(separator: " - "))
        name = course.name
        code = course.course_code
        color = course.course_color
    }
}
