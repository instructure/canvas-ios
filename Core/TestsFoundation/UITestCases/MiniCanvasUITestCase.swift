//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

open class MiniCanvasUITestCase: CoreUITestCase {
    override open var user: UITestUser? { nil }
    override open var useMocks: Bool { false }

    public var mocked: MiniCanvasState { MiniCanvasServer.shared.state }
    public var firstCourse: MiniCourse! { mocked.courses.first }
    public var firstAssignment: MiniAssignment! { mocked.courses.first?.assignments.first }

    open func setUpState() {
        let state = MiniCanvasServer.shared.state
        if Bundle.main.isStudentApp {
            state.selfId = state.students[0].id.value
        } else if Bundle.main.isTeacherApp {
            state.selfId = state.teachers[0].id.value
        }
    }

    override open func setUp() {
        MiniCanvasServer.shared.reset()
        setUpState()

        super.setUp()
        logInEntry(LoginSession(
            accessToken: "at",
            baseURL: MiniCanvasServer.shared.baseUrl,
            expiresAt: nil,
            locale: "en",
            refreshToken: nil,
            userID: "",
            userName: ""
        ))
    }
}
