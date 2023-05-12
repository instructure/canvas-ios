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

@testable import Core
import XCTest

class CourseSyncDiskSpaceInfoViewModelTests: XCTestCase {

    func testConvertsInteractorData() {
        let testee = CourseSyncDiskSpaceInfoViewModel(interactor: MockDiskSpaceInteractor(), app: .parent)
        XCTAssertEqual(testee.diskUsage, "512 bytes of 1 KB Used")
        XCTAssertEqual(testee.chart.0, 0.25)
        XCTAssertEqual(testee.chart.1, 0.25)
        XCTAssertEqual(testee.chart.2, 0.5)
        XCTAssertEqual(testee.appName, "Canvas Parent")
    }
}

private class MockDiskSpaceInteractor: DiskSpaceInteractor {

    func getDiskSpace() -> DiskSpace {
        DiskSpace(total: 1024,
                  available: 512,
                  app: 256,
                  otherApps: 256)
    }
}
