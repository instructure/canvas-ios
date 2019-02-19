//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core
import TestsFoundation

class DocViewerUseCaseTests: XCTestCase {
    class MockUseCase: DocViewerUseCase {
        var sequenceCount = 0
        var lastSequence: [Operation]?
        override func addSequence(_ operations: [Operation]) {
            lastSequence = operations
            sequenceCount += 1
        }
    }

    func testLoadSessionNone() {
        let api = MockAPI()
        api.accessToken = nil
        let use = MockUseCase(api: api, previewURL: URL(string: "/")!)
        let last = use.lastSequence?[1] as? BlockOperation
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertNil(use.sessionID)
        XCTAssertNil(use.sessionURL)
        XCTAssertEqual(use.sequenceCount, 1)
    }

    func testLoadSession() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        let first = use.lastSequence?[0] as? GetDocViewerSession
        let last = use.lastSequence?[1] as? BlockOperation
        first?.sessionURL = URL(string: "session/123")
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertEqual(use.sessionID, "123")
        XCTAssertNotNil(use.sessionURL)
        XCTAssertEqual(use.sequenceCount, 2)
    }

    func testLoadMetadataNone() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        use.loadMetadata(sessionID: "123", sessionURL: URL(string: "session/123")!)
        let last = use.lastSequence?[1] as? BlockOperation
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertNil(use.metadata)
        XCTAssertEqual(use.sequenceCount, 2)
    }

    func testLoadMetadata() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        use.loadMetadata(sessionID: "123", sessionURL: URL(string: "session/123")!)
        let first = use.lastSequence?[0] as? GetDocViewerMetadata
        let last = use.lastSequence?[1] as? BlockOperation
        first?.response = APIDocViewerMetadata(
            annotations: APIDocViewerAnnotationsMetadata(enabled: true, user_id: nil, user_name: nil, permissions: .read),
            panda_push: nil,
            rotations: nil,
            urls: APIDocViewerURLsMetadata(pdf_download: URL(string: "download")!)
        )
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertNotNil(use.metadata)
        XCTAssertEqual(use.sequenceCount, 4)
    }

    func testLoadAnnotationsNone() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        use.loadAnnotations(docViewerAPI: MockAPI(), sessionID: "123")
        let last = use.lastSequence?[1] as? BlockOperation
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertEqual(use.annotations, [])
    }

    func testLoadAnnotations() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        use.loadAnnotations(docViewerAPI: MockAPI(), sessionID: "123")
        let first = use.lastSequence?[0] as? GetDocViewerAnnotations
        let last = use.lastSequence?[1] as? BlockOperation
        first?.response = APIDocViewerAnnotations(data: [ APIDocViewerAnnotation.make() ])
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertEqual(use.annotations.count, 1)
    }

    func testLoadDocument() {
        let use = MockUseCase(api: MockAPI(), previewURL: URL(string: "/")!)
        use.loadDocument(docViewerAPI: MockAPI(), downloadURL: URL(string: "download")!)
        let first = use.lastSequence?[0] as? GetDocViewerDocument
        let last = use.lastSequence?[1] as? BlockOperation
        first?.localURL = URL(string: "local")
        OperationQueue().addOperations([last!], waitUntilFinished: true)
        XCTAssertEqual(use.localURL, URL(string: "local"))
    }
}
