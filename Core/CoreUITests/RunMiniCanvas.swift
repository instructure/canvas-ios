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
import TestsFoundation
@testable import Core

class RunMiniCanvas: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { RunMiniCanvas.self }

    override func setUp() {
    }

    func testJustServer() {
        MiniCanvasServer.shared.server.logResponses = true
        let state = MiniCanvasServer.shared.state
        if Bundle.main.isStudentApp {
            state.selfId = state.students[0].id
        } else if Bundle.main.isTeacherApp {
            state.selfId = state.teachers[0].id
        }

        let baseUrl = "\(MiniCanvasServer.shared.baseUrl)"
        let user = UITestUser(host: baseUrl, username: "", password: "")
        launch { app in
            app.launchEnvironment["OVERRIDE_MOBILE_VERIFY_URL"] = "\(baseUrl)api/v1/mobile_verify.json"
            app.launchArguments.append(contentsOf: [
                "-com.apple.configuration.managed",
                user.profile,
            ])
        }
        RunLoop.current.run()
    }
}
