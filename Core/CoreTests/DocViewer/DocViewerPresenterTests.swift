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
import PSPDFKitUI
@testable import Core

class DocViewerPresenterTests: CoreTestCase {
    var document: PSPDFDocument?
    var error: Error?
    var resetted = false

    let url = Bundle(for: DocViewerPresenterTests.self).url(forResource: "instructure", withExtension: "pdf")!

    class MockSession: DocViewerSession {
        var requested: URL?
        var loading: URL?
        override func load(url: URL, session: LoginSession) {
            requested = url
            notify()
        }
        override func loadDocument(downloadURL: URL) {
            loading = downloadURL
        }
    }
    lazy var session = MockSession { self.presenter.sessionIsReady() }

    lazy var presenter: DocViewerPresenter = {
        let presenter = DocViewerPresenter(env: environment, view: self, filename: "instructure.pdf", previewURL: url, fallbackURL: url)
        XCTAssertNoThrow(presenter.session)
        presenter.session = session
        return presenter
    }()

    func testViewIsReadyErrors() {
        let err = APIDocViewerError.noData
        session.error = err
        presenter.viewIsReady()
        wait(for: [expectation(for: .all, evaluatedWith: err) { self.error != nil }], timeout: 5)
        XCTAssertEqual(error as? APIDocViewerError, .noData)
    }

    func testViewIsReadyNoURL() {
        presenter.previewURL = nil
        presenter.viewIsReady()
        XCTAssertEqual(session.loading, presenter.fallbackURL)
    }

    func testSessionIsReady() {
        session.annotations = []
        session.sessionID = "abcd"
        session.sessionURL = URL(string: "session")
        session.localURL = url
        session.metadata = APIDocViewerMetadata.make(rotations: [ "0": 90 ])
        presenter.sessionIsReady()
        let providers = document?.documentProviders.first?.annotationManager.annotationProviders
        XCTAssertTrue(providers?.contains(where: { $0 is DocViewerAnnotationProvider }) ?? false)
    }

    func testLoadFallback() {
        session.localURL = url
        presenter.loadFallback()
        XCTAssertEqual(document?.fileURL, url)
    }

    func testLoadFallbackRepeat() {
        session.error = APIDocViewerError.noData
        presenter.loadFallback()
        XCTAssertNotNil(error)
        XCTAssertNil(session.error)
        XCTAssertEqual(presenter.fallbackUsed, true)

        session.error = APIDocViewerError.noData
        presenter.loadFallback()
        XCTAssertNotNil(session.error)
        XCTAssertNil(document)
        XCTAssertEqual(presenter.fallbackUsed, true)
    }

    func testShouldShowForSelectedText() {
        let menuItems: [PSPDFMenuItem] = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "test1", block: {}, identifier: PSPDFTextMenu.annotationMenuHighlight.rawValue),
        ]
        let results = presenter.pdfViewController(
            PSPDFViewController(),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            forSelectedText: "",
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0], menuItems[0])
    }

    class MockPDFViewController: PSPDFViewController {
        var presented: UIViewController?
        override func present(_ viewController: UIViewController, options: [String: Any]? = nil, animated: Bool, sender: Any?, completion: (() -> Void)? = nil) -> Bool {
            presented = viewController
            return false
        }
    }

    class MockPDFDocument: PSPDFDocument {
        var added: [PSPDFAnnotation]?
        override func add(_ annotations: [PSPDFAnnotation], options: [PSPDFAnnotationOption: Any]? = nil) -> Bool {
            added = annotations
            return false
        }

        var removed: [PSPDFAnnotation]?
        override func remove(_ annotations: [PSPDFAnnotation], options: [PSPDFAnnotationOption: Any]? = nil) -> Bool {
            removed = annotations
            return false
        }
    }

    class MockPDFPageView: PSPDFPageView {
        var annotationView: (UIView & PSPDFAnnotationPresenting)?
        override func annotationView(for annotation: PSPDFAnnotation) -> (UIView & PSPDFAnnotationPresenting)? {
            return annotationView
        }
    }

    func testShouldShowForNoAnnotations() {
        let menuItems = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "", block: {}, identifier: PSPDFTextMenu.annotationMenuOpacity.rawValue),
        ]
        let results = presenter.pdfViewController(
            PSPDFViewController(document: PSPDFDocument(url: url)),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: nil,
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results, [ menuItems[0] ])
    }

    func testShouldShowForAnnotations() {
        let menuItems = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "opacity", block: {}, identifier: PSPDFTextMenu.annotationMenuOpacity.rawValue),
            PSPDFMenuItem(title: "inspector", block: {}, identifier: PSPDFTextMenu.annotationMenuInspector.rawValue),
        ]
        presenter.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        let annotation = PSPDFNoteAnnotation(contents: "note")
        annotation.isEditable = false
        let results = presenter.pdfViewController(
            viewController,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [annotation],
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results[0].title, "Comments")
        XCTAssertEqual(results[1].title, "test")
        XCTAssertEqual(results[2].title, "Style")
        XCTAssertEqual(results[3].identifier, PSPDFTextMenu.annotationMenuRemove.rawValue)

        results[0].performBlock()
        XCTAssert(viewController.presented is UINavigationController)

        results[3].performBlock()
        XCTAssertEqual((viewController.document as? MockPDFDocument)?.removed, [annotation])
    }

    func testShouldShowForAnnotationsDontAllowRotating() {
        let menuItems = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "opacity", block: {}, identifier: PSPDFTextMenu.annotationMenuOpacity.rawValue),
            PSPDFMenuItem(title: "inspector", block: {}, identifier: PSPDFTextMenu.annotationMenuInspector.rawValue),
        ]
        presenter.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        let annotation = PSPDFFreeTextAnnotation(contents: "text")
        let pageView = MockPDFPageView(frame: .zero)
        let annotationView = PSPDFFreeTextAnnotationView()
        let resizableView = PSPDFResizableView()
        annotationView.resizableView = resizableView
        pageView.annotationView = annotationView
        _ = presenter.pdfViewController(
            viewController,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [annotation],
            in: .zero,
            on: pageView
        )
        XCTAssertFalse(resizableView.allowRotating)
    }

    func testShouldShowController() {
        XCTAssertFalse(presenter.pdfViewController(PSPDFViewController(), shouldShow: PSPDFStampViewController(), animated: true))
        XCTAssertTrue(presenter.pdfViewController(PSPDFViewController(), shouldShow: UIViewController(), animated: true))
    }

    func testDidTapOn() {
        XCTAssertFalse(presenter.pdfViewController(PSPDFViewController(), didTapOn: PSPDFPageView(frame: .zero), at: .zero))

        presenter.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        viewController.annotationStateManager.state = .stamp
        XCTAssertTrue(presenter.pdfViewController(viewController, didTapOn: PSPDFPageView(frame: .zero), at: .zero))
        XCTAssert(viewController.presented is UINavigationController)
        XCTAssertEqual((viewController.document as? MockPDFDocument)?.added?.count, 1)
    }

    func testAnnotationDidExceedLimit() {
        presenter.annotationDidExceedLimit(annotation: APIDocViewerAnnotation.make())
        XCTAssertFalse(resetted)
        presenter.annotationDidExceedLimit(annotation: APIDocViewerAnnotation.make(type: .ink))
        XCTAssertTrue(resetted)
    }

    func testAnnotationDidFailToSave() {
        presenter.annotationDidFailToSave(error: APIDocViewerError.tooBig)
        // TODO: save status bar
    }

    func testAnnotationSaveStateChanges() {
        presenter.annotationSaveStateChanges(saving: true)
        // TODO: save status bar
    }
}

extension DocViewerPresenterTests: DocViewerViewProtocol {
    func load(document: PSPDFDocument) {
        self.document = document
    }

    func resetInk() {
        resetted = true
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        self.error = error
    }
}
