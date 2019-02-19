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
import PSPDFKitUI
@testable import Core

class DocViewerPresenterTests: CoreTestCase {
    var document: PSPDFDocument?
    var error: Error?
    var resetted = false

    let url = Bundle(for: DocViewerPresenterTests.self).url(forResource: "instructure", withExtension: "pdf")!

    class MockUseCase: DocViewerUseCase {
        override func execute() { finish() }
    }
    lazy var mockUseCase: MockUseCase = {
        return MockUseCase(api: api, previewURL: url)
    }()

    lazy var presenter: DocViewerPresenter = {
        return DocViewerPresenter(env: environment, view: self, filename: "instructure.pdf", previewURL: url, fallbackURL: url) { (_: Bool) in
            return self.mockUseCase
        }
    }()

    func testUseCaseFactory() {
        let presenter = DocViewerPresenter(env: environment, view: self, filename: "instructure.pdf", previewURL: url, fallbackURL: url)
        XCTAssertEqual(presenter.useCaseFactory(false).errors.count, 0)
    }

    func testViewIsReady() {
        let err = APIDocViewerError.noData
        mockUseCase.addError(err)
        presenter.viewIsReady()
        wait(for: [expectation(for: .all, evaluatedWith: err) { self.error != nil }], timeout: 5)
        XCTAssertEqual(error as? APIDocViewerError, .noData)
    }

    func testLoadDataFromServer() {
        mockUseCase.sessionID = "abcd"
        mockUseCase.sessionURL = URL(string: "session")
        mockUseCase.localURL = url
        mockUseCase.metadata = APIDocViewerMetadata.make([ "rotations": [ "0": 90 ] ])
        presenter.loadDataFromServer()
        wait(for: [expectation(for: .all, evaluatedWith: api) { self.document != nil }], timeout: 5)
        XCTAssertTrue(document?.documentProviders.first?.annotationManager.annotationProviders.contains(where: { $0 is DocViewerAnnotationProvider }) ?? false)
    }

    func testShouldShowForSelectedText() {
        let menuItems = [ PSPDFMenuItem(title: "test", block: {}) ]
        let results = presenter.pdfViewController(
            PSPDFViewController(),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            forSelectedText: "",
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results, menuItems)
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
        presenter.annotationDidExceedLimit(annotation: APIDocViewerAnnotation.make([ "type": "ink" ]))
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

    var navigationController: UINavigationController? {
        return nil
    }

    func showError(_ error: Error) {
        self.error = error
    }
}
