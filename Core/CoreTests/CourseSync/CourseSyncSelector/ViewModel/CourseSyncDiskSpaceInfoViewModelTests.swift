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
        let diskSpace = DiskSpace(total: 1024,
                                  available: 640,
                                  app: 256,
                                  otherApps: 128)
        let testee = CourseSyncDiskSpaceInfoViewModel(interactor: MockDiskSpaceInteractor(diskSpace: diskSpace),
                                                      app: .parent)
        XCTAssertEqual(testee.diskUsage, "384 bytes of 1 KB Used")
        XCTAssertEqual(testee.chart.other, 0.125)
        XCTAssertEqual(testee.chart.app, 0.25)
        XCTAssertEqual(testee.chart.free, 0.625)
        XCTAssertEqual(testee.appName, "Canvas Parent")
    }

    func testReserves1PercentChartForAppData() {
        let diskSpace = DiskSpace(total: 1024,
                                  available: 512,
                                  app: 0,
                                  otherApps: 512)
        let testee = CourseSyncDiskSpaceInfoViewModel(interactor: MockDiskSpaceInteractor(diskSpace: diskSpace),
                                                      app: .parent)
        XCTAssertEqual(testee.chart.other, 0.5)
        XCTAssertEqual(testee.chart.app, 0.01)
        XCTAssertEqual(testee.chart.free, 0.49)
    }

    func testA11yLabel() {
        let diskSpace = DiskSpace(total: 1024,
                                  available: 640,
                                  app: 256,
                                  otherApps: 128)
        let testee = CourseSyncDiskSpaceInfoViewModel(interactor: MockDiskSpaceInteractor(diskSpace: diskSpace),
                                                      app: .parent)
        XCTAssertEqual(testee.a11yLabel, "Storage Info,384 bytes of 1 KB Used,Other Apps 12.5%,Canvas Parent 25.0%,Remaining 62.5%")
    }
}

private class MockDiskSpaceInteractor: DiskSpaceInteractor {
    private var diskSpace: DiskSpace

    init(diskSpace: DiskSpace) {
        self.diskSpace = diskSpace
    }

    func getDiskSpace() -> DiskSpace {
        diskSpace
    }
}
