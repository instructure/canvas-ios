//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Core
import TestsFoundation
import XCTest
import CoreData

class SubmitAssignmentTests: XCTestCase {
    let env = AppEnvironment.shared
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    let uploadManager = MockUploadManager()
    let sessionsBackup = LoginSession.sessions

    override func setUp() {
        super.setUp()

        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        MockURLSession.reset()
        UploadManager.shared = uploadManager
        env.database = database
        env.api = URLSessionAPI()
    }

    override func tearDown() {
        LoginSession.sessions = sessionsBackup
    }
}
