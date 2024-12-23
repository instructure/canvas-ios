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

class FilePreviewProviderTests: XCTestCase {

    func testUnknownFilePreview() {
        let testee = FilePreviewProvider(url: url(fileExtension: "bin"))
        let noDataExpectation = expectation(description: "No data should be received")
        noDataExpectation.isInverted = true
        let errorExpectation = expectation(description: "Error received")
        let subscription = testee.result.sink { completion in
            if case .failure = completion {
                errorExpectation.fulfill()
            }
        } receiveValue: { _ in
            noDataExpectation.fulfill()
        }
        testee.load()
        waitForExpectations(timeout: 0.5)
        subscription.cancel()
    }

    func testPNGImagePreview() {
        let testee = FilePreviewProvider(url: url(fileExtension: "png"))
        let dataExpectation = expectation(description: "Preview data should be received")
        let errorExpectation = expectation(description: "No error received")
        errorExpectation.isInverted = true
        let subscription = testee.result.sink { completion in
            if case .failure = completion {
                errorExpectation.fulfill()
            }
        } receiveValue: { data in
            dataExpectation.fulfill()
            XCTAssertNil(data.duration)
            XCTAssertNotNil(data.image)
        }
        testee.load()
        waitForExpectations(timeout: 0.5)
        subscription.cancel()
    }

    func testPDFPreview() {
        let testee = FilePreviewProvider(url: url(fileExtension: "pdf"))
        let dataExpectation = expectation(description: "Preview data should be received")
        let errorExpectation = expectation(description: "No error received")
        errorExpectation.isInverted = true
        let subscription = testee.result.sink { completion in
            if case .failure = completion {
                errorExpectation.fulfill()
            }
        } receiveValue: { data in
            dataExpectation.fulfill()
            XCTAssertNil(data.duration)
            XCTAssertNotNil(data.image)
        }
        testee.load()
        waitForExpectations(timeout: 0.5)
        subscription.cancel()
    }

    func testMP4Preview() {
        let testee = FilePreviewProvider(url: url(fileExtension: "mp4"))
        let dataExpectation = expectation(description: "Preview data should be received")
        let finishExpectation = expectation(description: "Stream finished")
        let subscription = testee.result.sink { completion in
            if case .failure = completion {
                XCTFail("Stream should have finished successfully.")
            }
            finishExpectation.fulfill()
        } receiveValue: { data in
            dataExpectation.fulfill()
            XCTAssertEqual(data.duration ?? 0, 4.5, accuracy: 0.1)
            XCTAssertNotNil(data.image)
        }
        testee.load()
        waitForExpectations(timeout: 5)
        subscription.cancel()
    }

    private func url(fileName: String = "preview_test", fileExtension: String) -> URL {
        Bundle(for: FilePreviewProviderTests.self).url(forResource: fileName, withExtension: fileExtension)!
    }
}
