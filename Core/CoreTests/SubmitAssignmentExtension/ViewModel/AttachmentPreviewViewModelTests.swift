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

import Combine
@testable import Core
import XCTest

class AttachmentPreviewViewModelTests: XCTestCase {

    func testLoadingStateIsDefault() {
        let testee = AttachmentPreviewViewModel(previewProvider: MockFilePreviewProvider())
        XCTAssertEqual(testee.state, .loading)
    }

    func testMapsErrorToNoPreviewState() {
        let testee = AttachmentPreviewViewModel(previewProvider: MockFilePreviewProvider(error: NSError.internalError()))
        drainMainQueue()
        XCTAssertEqual(testee.state, .noPreview)
    }

    func testMapsMediaWithoutDuration() {
        let testee = AttachmentPreviewViewModel(previewProvider: MockFilePreviewProvider(previewData: .init(image: .checkmark, duration: nil)))
        drainMainQueue()
        XCTAssertEqual(testee.state, .media(image: .checkmark, length: nil))
    }

    func testMapsMediaWithDuration() {
        let testee = AttachmentPreviewViewModel(previewProvider: MockFilePreviewProvider(previewData: .init(image: .checkmark, duration: 183)))
        drainMainQueue()
        XCTAssertEqual(testee.state, .media(image: .checkmark, length: "03:03"))
    }
}

class MockFilePreviewProvider: FilePreviewProvider {
    override public var result: AnyPublisher<PreviewData, Error> { mockResult }
    private let mockResult: AnyPublisher<PreviewData, Error>
    private let resultSubject = PassthroughSubject<PreviewData, Error>()

    private let previewData: PreviewData?
    private let error: Error?

    init(previewData: PreviewData? = nil, error: Error? = nil) {
        self.mockResult = resultSubject.eraseToAnyPublisher()
        self.previewData = previewData
        self.error = error
        super.init(url: .stub)
    }

    override func load() {
        if let error = error {
            resultSubject.send(completion: .failure(error))
        } else if let previewData = previewData {
            resultSubject.send(previewData)
            resultSubject.send(completion: .finished)
        }
    }
}
