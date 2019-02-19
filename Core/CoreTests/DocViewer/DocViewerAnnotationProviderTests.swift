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
import PSPDFKit
import TestsFoundation
@testable import Core

class DocViewerAnnotationProviderTests: XCTestCase {
    let api = MockAPI()

    class Delegate: DocViewerAnnotationProviderDelegate {
        var annotation: APIDocViewerAnnotation?
        var error: Error?
        var saving: Bool = false
        func annotationDidExceedLimit(annotation: APIDocViewerAnnotation) {
            self.annotation = annotation
        }
        func annotationDidFailToSave(error: Error) {
            self.error = error
        }
        func annotationSaveStateChanges(saving: Bool) {
            self.saving = saving
        }
    }

    func getProvider(
        annotations: [APIDocViewerAnnotation] = [ APIDocViewerAnnotation.make() ],
        enabled: Bool = true,
        permissions: APIDocViewerPermissions = .readwritemanage
    ) -> DocViewerAnnotationProvider {
        let document = PSPDFDocument(url: Bundle(for: DocViewerAnnotationProviderTests.self).url(forResource: "instructure", withExtension: "pdf")!)
        let metadata = APIDocViewerAnnotationsMetadata(enabled: enabled, user_id: "1", user_name: "a", permissions: permissions)
        let documentProvider = document.documentProviders.first!
        let provider = DocViewerAnnotationProvider(
            documentProvider: documentProvider,
            metadata: metadata,
            annotations: annotations,
            api: api,
            sessionID: "a"
        )
        documentProvider.annotationManager.annotationProviders.insert(provider, at: 0)
        return provider
    }

    func testInit() {
        XCTAssertEqual(getProvider().allAnnotations.count, 1)
        XCTAssertEqual(getProvider(enabled: false).allAnnotations.count, 0)
    }

    func testGetReplies() {
        let provider = getProvider(annotations: [
            APIDocViewerAnnotation.make([ "id": "2", "type": "commentReply", "inreplyto": "1" ]),
            APIDocViewerAnnotation.make([ "id": "3", "type": "commentReply", "inreplyto": "1" ]),
        ])
        XCTAssertEqual(provider.getReplies(to: try PSPDFAnnotation(dictionary: ["name": "1"])).count, 2)
    }

    func testAddNoData() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"))
        XCTAssertEqual(provider.add([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testAddTooBig() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), error: APIDocViewerError.tooBig)
        XCTAssertEqual(provider.add([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.annotation, annotation.apiAnnotation())
    }

    func testAddEmpty() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerCommentReplyAnnotation(contents: "")
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"))
        XCTAssertEqual(provider.add([ annotation ])?.count, 1)
        XCTAssertNil(delegate.error)
    }

    func testAddUnsupported() {
        let provider = getProvider()
        let annotation = try! PSPDFSoundAnnotation(dictionary: nil)
        XCTAssertEqual(provider.add([ annotation ])?.count, 0)
    }

    func testAddSuccess() {
        let provider = getProvider()
        let annotation = DocViewerPointAnnotation(image: nil)
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: annotation.apiAnnotation())
        XCTAssertEqual(provider.add([ annotation ])?.count, 1)
    }

    func testRemoveError() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "1" ])
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "a"), error: APIDocViewerError.noData)
        XCTAssertEqual(provider.remove([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testRemoveUnknown() {
        let provider = getProvider()
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "bogus" ])
        XCTAssertEqual(provider.remove([ annotation ])?.count, 0)
    }

    func testRemoveSuccess() {
        let provider = getProvider()
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "1" ])
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "a"))
        XCTAssertEqual(provider.remove([ annotation ])?.count, 1)
    }

    func testChangeNoData() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"))
        provider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testChangeTooBig() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = PSPDFInkAnnotation(lines: (0...120).map {
            return [ NSValue.pspdf_value(with: PSPDFDrawingPoint(location: CGPoint(x: $0, y: $0), intensity: 1)) ]
        })
        provider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.annotation, annotation.apiAnnotation())
    }

    func testChangeEmpty() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerCommentReplyAnnotation(contents: "")
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"))
        provider.didChange(annotation, keyPaths: [])
        XCTAssertNil(delegate.error)
    }

    func testChangeUnsupported() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = try! PSPDFSoundAnnotation(dictionary: nil)
        provider.didChange(annotation, keyPaths: [])
        XCTAssertNil(delegate.error)
    }

    func testChangeSuccess() {
        let provider = getProvider()
        let annotation = DocViewerPointAnnotation(image: nil)
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: annotation.apiAnnotation())
        provider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(provider.apiAnnotations.count, 2)
    }

    func testSyncAllAnnotations() {
        let provider = getProvider(annotations: [])
        provider.requestsInFlight = 1234
        provider.syncAllAnnotations()
        XCTAssertEqual(provider.requestsInFlight, 0)
    }
}
