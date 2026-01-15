//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import TestsFoundation
import XCTest

final class AcknowledgeFileUploadInteractorTests: HorizonTestCase {

    // MARK: - Properties

    private var interactor: AcknowledgeFileUploadInteractorLive!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        API.resetMocks()
        interactor = AcknowledgeFileUploadInteractorLive(api: api)
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeFile(
        id: String = "file-123",
        url: URL? = nil,
        createdAt: Date? = Date()
    ) -> File {
        let file = File.make()
        file.id = id
        file.url = url
        file.createdAt = createdAt
        return file
    }

    // MARK: - Tests

    func test_acknowledgeUpload_shouldMakeGetRequest_whenURLIsSet() {
        let file = makeFile()
        let fileURL = URL(string: "https://example.com/file.pdf")!

        let kvoExpectation = XCTKVOExpectation(
            keyPath: "url",
            object: file,
            expectedValue: fileURL
        )

        api.mock(url: fileURL, method: .get, data: Data())

        interactor.acknowledgeUpload(of: file)
        file.url = fileURL

        wait(for: [kvoExpectation], timeout: 1.0)
    }
}
