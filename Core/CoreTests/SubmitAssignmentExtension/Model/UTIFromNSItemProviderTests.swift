//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class UTIFromNSItemProviderTests: XCTestCase {

    func testValidUTI() {
        XCTAssertEqual(MockNSItemProvider(isSupported: true).uti, NSItemProvider.SupportedUTIs[0])
    }

    func testValidUTIReportsNothingToAnalytics() {
        let mockRemoteLogHandler = MockRemoteLogHandler()
        RemoteLogger.shared.handler = mockRemoteLogHandler

        _ = MockNSItemProvider(isSupported: true).uti

        XCTAssertEqual(mockRemoteLogHandler.totalErrorCount, 0)
        XCTAssertNil(mockRemoteLogHandler.lastErrorName)
        XCTAssertNil(mockRemoteLogHandler.lastErrorReason)
    }

    func testInvalidUTI() {
        XCTAssertNil(MockNSItemProvider(isSupported: false).uti)
    }

    func testInvalidUTIReportsToAnalytics() {
        let mockRemoteLogHandler = MockRemoteLogHandler()
        RemoteLogger.shared.handler = mockRemoteLogHandler

        _ = MockNSItemProvider(isSupported: false).uti

        XCTAssertEqual(mockRemoteLogHandler.totalErrorCount, 1)
        XCTAssertEqual(mockRemoteLogHandler.lastErrorName, "Unsupported file type")
        XCTAssertEqual(mockRemoteLogHandler.lastErrorReason, "test.pcx")
    }
}

class MockNSItemProvider: NSItemProvider {
    private let isSupported: Bool

    init(isSupported: Bool) {
        self.isSupported = isSupported
        super.init()
        self.suggestedName = "test.pcx"
    }

    override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
        isSupported
    }
}
