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

class DocViewerAnnotationProviderTests: CoreTestCase {
    class MockDelegate: DocViewerAnnotationProviderDelegate {
        enum Event: Equatable {
            case exceededLimit
            case failedToSave
            case saveStateChanged(isSaving: Bool)
        }
        var annotation: APIDocViewerAnnotation?
        var error: Error?
        var saving: Bool = false
        var callStack: [Event] = []

        func annotationDidExceedLimit(annotation: APIDocViewerAnnotation) {
            self.annotation = annotation
            error = nil
            saving = false
            callStack.append(.exceededLimit)
        }
        func annotationDidFailToSave(error: Error) {
            annotation = nil
            self.error = error
            saving = false
            callStack.append(.failedToSave)
        }
        func annotationSaveStateChanges(saving: Bool) {
            annotation = nil
            error = nil
            self.saving = saving
            callStack.append(.saveStateChanged(isSaving: saving))
        }
    }

    func getProviders(
        annotations: [APIDocViewerAnnotation] = [ APIDocViewerAnnotation.make() ],
        enabled: Bool = true,
        permissions: APIDocViewerPermissions = .readwritemanage,
        isAnnotationEditingDisabled: Bool = false,
        useMockFileAnnotationProvider: Bool = false
    ) -> (annotationProvider: DocViewerAnnotationProvider, documentProvider: PDFDocumentProvider) {
        let document = Document(url: Bundle(for: DocViewerAnnotationProviderTests.self).url(forResource: "instructure", withExtension: "pdf")!)
        let metadata = APIDocViewerAnnotationsMetadata(enabled: enabled, user_id: "1", user_name: "a", permissions: permissions)
        let documentProvider = document.documentProviders.first!
        let fileAnnotationProvider = useMockFileAnnotationProvider ? MockPDFFileAnnotationProvider(documentProvider: documentProvider) : documentProvider.annotationManager.fileAnnotationProvider!
        let provider = DocViewerAnnotationProvider(
            documentProvider: documentProvider,
            fileAnnotationProvider: fileAnnotationProvider,
            metadata: APIDocViewerMetadata(
                annotations: metadata,
                panda_push: nil,
                rotations: nil,
                urls: APIDocViewerURLsMetadata(pdf_download: APIURL.make().rawValue)
            ),
            apiAnnotations: annotations,
            api: environment.api,
            sessionID: "a",
            isAnnotationEditingDisabled: isAnnotationEditingDisabled
        )
        documentProvider.annotationManager.annotationProviders.append(provider)

        // Annotation provider only keeps a weak reference to the PDFDocumentProvider so we have to return it to be kept alive
        return (annotationProvider: provider, documentProvider: documentProvider)
    }

    func testInit() {
        XCTAssertEqual(getProviders().annotationProvider.allAnnotations.count, 1)
        XCTAssertEqual(getProviders(enabled: false).annotationProvider.allAnnotations.count, 0)
    }

    func testGetReplies() {
        let provider = getProviders(annotations: [
            APIDocViewerAnnotation.make(id: "2", type: .commentReply, inreplyto: "1"),
            APIDocViewerAnnotation.make(id: "3", type: .commentReply, inreplyto: "1"),
        ])
        XCTAssertEqual(provider.annotationProvider.getReplies(to: try Annotation(dictionary: ["name": "1"])).count, 2)
    }

    func testAddNoData() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), error: APIDocViewerError.noData)
        XCTAssertEqual(providers.annotationProvider.add([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testAddTooBig() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), error: APIDocViewerError.tooBig)
        XCTAssertEqual(providers.annotationProvider.add([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.annotation, annotation.apiAnnotation())
    }

    func testAddEmpty() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerCommentReplyAnnotation(contents: "")
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        XCTAssertEqual(providers.annotationProvider.add([ annotation ])?.count, 1)
        XCTAssertNil(delegate.error)
    }

    func testAddUnsupported() {
        let provider = getProviders()
        let annotation = try! SoundAnnotation(dictionary: nil)
        XCTAssertEqual(provider.annotationProvider.add([ annotation ])?.count, 0)
    }

    func testAddSuccess() {
        let delegate = MockDelegate()
        let providers = getProviders()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation(image: nil)
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: annotation.apiAnnotation())
        XCTAssertEqual(providers.annotationProvider.add([ annotation ])?.count, 1)
        XCTAssertNil(delegate.error)
    }

    func testRemoveError() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "1" ])
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "a"), error: APIDocViewerError.noData)
        XCTAssertEqual(providers.annotationProvider.remove([ annotation ])?.count, 1)
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testRemoveUnknown() {
        let providers = getProviders()
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "bogus" ])
        XCTAssertEqual(providers.annotationProvider.remove([ annotation ])?.count, 1)
    }

    func testRemoveSuccess() {
        let providers = getProviders()
        let annotation = try! DocViewerPointAnnotation(dictionary: [ "name": "1" ])
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "a"), value: nil)
        XCTAssertEqual(providers.annotationProvider.remove([ annotation ])?.count, 1)
    }

    func testChangeNoData() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation()
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        providers.annotationProvider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.error as? APIDocViewerError, APIDocViewerError.noData)
    }

    func testChangeEmpty() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerCommentReplyAnnotation(contents: "")
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: nil)
        providers.annotationProvider.didChange(annotation, keyPaths: [])
        XCTAssertNil(delegate.error)
    }

    func testChangeUnsupported() {
        let providers = getProviders()
        let delegate = MockDelegate()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = try! SoundAnnotation(dictionary: nil)
        providers.annotationProvider.didChange(annotation, keyPaths: [])
        XCTAssertNil(delegate.error)
    }

    func testChangeSuccess() {
        let delegate = MockDelegate()
        let providers = getProviders()
        providers.annotationProvider.docViewerDelegate = delegate
        let annotation = DocViewerPointAnnotation(image: nil)
        api.mock(PutDocViewerAnnotationRequest(body: annotation.apiAnnotation(), sessionID: "a"), value: annotation.apiAnnotation())
        providers.annotationProvider.didChange(annotation, keyPaths: [])
        XCTAssertEqual(delegate.callStack, [.saveStateChanged(isSaving: true), .saveStateChanged(isSaving: false)])
        XCTAssertNil(delegate.error)
    }

    func testUserAnnotationIsReadOnlyWhenAnnotationIsDisabled() {
        let providers = getProviders(isAnnotationEditingDisabled: true)

        guard let annotation = providers.annotationProvider.allAnnotations.first else { XCTFail("No annotations to test"); return }

        XCTAssertTrue(annotation.flags.contains(.readOnly))
    }

    func testAnnotationFromPDFIsReadOnlyWhenAnnotatingIsEnabled() {
        let providers = getProviders(annotations: [], isAnnotationEditingDisabled: false, useMockFileAnnotationProvider: true)

        guard let annotation = providers.annotationProvider.annotationsForPage(at: 0)?.first else { XCTFail("No annotations to test"); return }

        XCTAssertFalse(annotation.isEditable)
    }

    func testAnnotationFromPDFIsReadOnlyWhenAnnotatingIsDisabled() {
        let providers = getProviders(annotations: [], isAnnotationEditingDisabled: true, useMockFileAnnotationProvider: true)

        guard let annotation = providers.annotationProvider.annotationsForPage(at: 0)?.first else { XCTFail("No annotations to test"); return }

        XCTAssertFalse(annotation.isEditable)
    }

    func testAnnotationFromPDFIsFlagged() {
        let providers = getProviders(annotations: [], isAnnotationEditingDisabled: true, useMockFileAnnotationProvider: true)

        guard let fileAnnotation = providers.annotationProvider.annotationsForPage(at: 0)?.first else { XCTFail("No annotations to test"); return }

        XCTExpectFailure("Will work when pspdfkit releases an update.") {
            XCTAssertTrue(fileAnnotation.isFileAnnotation)
        }
    }
}

class MockPDFFileAnnotationProvider: PDFFileAnnotationProvider {

    override func annotationsForPage(at pageIndex: PageIndex) -> [Annotation]? {
        [Annotation.from(.make(), metadata: .make())!]
    }
}
