//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
import PSPDFKit
import TestsFoundation
@testable import Core

class DocViewerAnnotationProviderTests: XCTestCase {
    let api = MockURLSession.self

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

    override func setUp() {
        super.setUp()
        MockURLSession.reset()
    }

    func getProvider(
        annotations: [APIDocViewerAnnotation] = [ APIDocViewerAnnotation.make() ],
        enabled: Bool = true,
        permissions: APIDocViewerPermissions = .readwritemanage
    ) -> DocViewerAnnotationProvider {
        let document = Document(url: Bundle(for: DocViewerAnnotationProviderTests.self).url(forResource: "instructure", withExtension: "pdf")!)
        let metadata = APIDocViewerAnnotationsMetadata(enabled: enabled, user_id: "1", user_name: "a", permissions: permissions)
        let documentProvider = document.documentProviders.first!
        let provider = DocViewerAnnotationProvider(
            documentProvider: documentProvider,
            metadata: metadata,
            annotations: annotations,
            api: URLSessionAPI(urlSession: MockURLSession()),
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
            APIDocViewerAnnotation.make(id: "2", type: .commentReply, inreplyto: "1"),
            APIDocViewerAnnotation.make(id: "3", type: .commentReply, inreplyto: "1"),
        ])
        XCTAssertEqual(provider.getReplies(to: try Annotation(dictionary: ["name": "1"])).count, 2)
    }

    func testAddNoData() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), error: APIDocViewerError.noData)
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
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        XCTAssertEqual(provider.add([ annotation ])?.count, 1)
        XCTAssertNil(delegate.error)
    }

    func testAddUnsupported() {
        let provider = getProvider()
        let annotation = try! SoundAnnotation(dictionary: nil)
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
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "a"), value: nil)
        XCTAssertEqual(provider.remove([ annotation ])?.count, 1)
    }

    func testChangeNoData() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        provider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testChangeTooBig() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = InkAnnotation(lines: (0...120).map {
            return [ DrawingPoint(location: CGPoint(x: $0, y: $0), intensity: 1) ]
        })
        provider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.annotation, annotation.apiAnnotation())
    }

    func testChangeEmpty() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = DocViewerCommentReplyAnnotation(contents: "")
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        provider.didChange(annotation, keyPaths: [])
        XCTAssertNil(delegate.error)
    }

    func testChangeUnsupported() {
        let provider = getProvider()
        let delegate = Delegate()
        provider.docViewerDelegate = delegate
        let annotation = try! SoundAnnotation(dictionary: nil)
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
