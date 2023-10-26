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

import Combine
@testable import Core

class BackgroundActivityMock: BackgroundActivity {
    var startInvoked = false
    var stopInvoked = false
    var abortHandler: (() -> Void)?

    init() {
        super.init(processManager: ProcessInfo.processInfo, activityName: "test activity")
    }

    override func start(abortHandler: @escaping () -> Void) -> Future<Void, Never> {
        self.abortHandler = abortHandler
        startInvoked = true
        return Future { $0(.success(())) }
    }

    override func stop() -> Future<Void, Never> {
        stopInvoked = true
        return Future { $0(.success(())) }
    }

    override func stopAndWait() {
        stopInvoked = true
    }

    func resetMock() {
        startInvoked = false
        stopInvoked = false
    }
}
