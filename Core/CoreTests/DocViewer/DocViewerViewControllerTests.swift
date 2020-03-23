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

class DocViewerViewControllerTests: CoreTestCase {
    lazy var controller: DocViewerViewController = {
        let controller = DocViewerViewController.create(
            filename: "instructure.pdf",
            previewURL: url, fallbackURL: url,
            navigationItem: navigationItem
        )
        controller.session = session
        return controller
    }()
    let navigationItem = UINavigationItem()
    lazy var url = Bundle(for: Self.self).url(forResource: "instructure", withExtension: "pdf")!

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
    lazy var session = MockSession { [weak self] in self?.controller.sessionIsReady() }

    func testOriginalSession() {
        let controller = DocViewerViewController.create(
            filename: "instructure.pdf",
            previewURL: url, fallbackURL: url,
            navigationItem: navigationItem
        )
        XCTAssertNoThrow(controller.session.notify())
    }

    func testViewIsReadyErrors() {
        let err = APIDocViewerError.noData
        session.error = err
        controller.view.layoutIfNeeded()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, err.localizedDescription)
    }

    func testFallback() {
        controller.previewURL = nil
        controller.view.layoutIfNeeded()
        XCTAssertEqual(session.loading, controller.fallbackURL)
    }

    func testSessionIsReady() {
        session.annotations = []
        session.sessionID = "abcd"
        session.sessionURL = URL(string: "session")
        session.localURL = url
        session.metadata = APIDocViewerMetadata.make(rotations: [ "0": 90 ])
        controller.view.layoutIfNeeded()
        let providers = controller.pdf.document?.documentProviders.first?.annotationManager.annotationProviders
        XCTAssertTrue(providers?.contains(where: { $0 is DocViewerAnnotationProvider }) ?? false)
    }

    func testLoadFallback() {
        session.localURL = url
        controller.previewURL = nil
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.pdf.document?.fileURL, url)
    }

    func testLoadFallbackRepeat() {
        session.error = APIDocViewerError.noData
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(router.presented)
        XCTAssertEqual(controller.fallbackUsed, true)

        session.error = APIDocViewerError.noData
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.pdf.document)
        XCTAssertEqual(controller.fallbackUsed, true)
    }

    func testShouldShowForSelectedText() {
        let menuItems: [PSPDFMenuItem] = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "test1", block: {}, identifier: PSPDFTextMenu.annotationMenuHighlight.rawValue),
        ]
        controller.view.layoutIfNeeded()
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            forSelectedText: "",
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?[0], menuItems[0])
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
        controller.view.layoutIfNeeded()
        let results = controller.pdf.delegate?.pdfViewController?(
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
        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        let annotation = PSPDFNoteAnnotation(contents: "note")
        annotation.isEditable = false
        let results = controller.pdf.delegate?.pdfViewController?(
            viewController,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [annotation],
            in: .zero,
            on: PSPDFPageView(frame: .zero)
        )
        XCTAssertEqual(results?[0].title, "Comments")
        XCTAssertEqual(results?[1].title, "test")
        XCTAssertEqual(results?[2].title, "Style")
        XCTAssertEqual(results?[3].identifier, PSPDFTextMenu.annotationMenuRemove.rawValue)

        results?[0].performBlock()
        XCTAssert(viewController.presented is UINavigationController)

        results?[3].performBlock()
        XCTAssertEqual((viewController.document as? MockPDFDocument)?.removed, [annotation])
    }

    func testShouldShowForAnnotationsDontAllowRotating() {
        let menuItems = [
            PSPDFMenuItem(title: "test", block: {}),
            PSPDFMenuItem(title: "opacity", block: {}, identifier: PSPDFTextMenu.annotationMenuOpacity.rawValue),
            PSPDFMenuItem(title: "inspector", block: {}, identifier: PSPDFTextMenu.annotationMenuInspector.rawValue),
        ]
        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        let annotation = PSPDFFreeTextAnnotation(contents: "text")
        let pageView = MockPDFPageView(frame: .zero)
        let annotationView = PSPDFFreeTextAnnotationView()
        let resizableView = PSPDFResizableView()
        annotationView.resizableView = resizableView
        pageView.annotationView = annotationView
        _ = controller.pdf.delegate?.pdfViewController?(
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
        XCTAssertFalse(controller.pdfViewController(PSPDFViewController(), shouldShow: PSPDFStampViewController(), animated: true))
        XCTAssertTrue(controller.pdfViewController(PSPDFViewController(), shouldShow: UIViewController(), animated: true))
    }

    func testDidTapOn() {
        XCTAssertFalse(controller.pdfViewController(PSPDFViewController(), didTapOn: PSPDFPageView(frame: .zero), at: .zero))

        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        let viewController = MockPDFViewController(document: MockPDFDocument(url: url))
        viewController.annotationStateManager.state = .stamp
        XCTAssertTrue(controller.pdfViewController(viewController, didTapOn: PSPDFPageView(frame: .zero), at: .zero))
        XCTAssert(viewController.presented is UINavigationController)
        XCTAssertEqual((viewController.document as? MockPDFDocument)?.added?.count, 1)
    }

    func testAnnotationDidExceedLimit() {
        controller.pdf.annotationStateManager.toggleState(.ink, variant: .inkPen)
        controller.annotationDidExceedLimit(annotation: APIDocViewerAnnotation.make())
        controller.annotationDidExceedLimit(annotation: APIDocViewerAnnotation.make(type: .ink))
        XCTAssertEqual(controller.pdf.annotationStateManager.variant, .inkPen)
    }

    func testAnnotationDidFailToSave() {
        controller.view.layoutIfNeeded()
        controller.annotationDidFailToSave(error: APIDocViewerError.tooBig)
        XCTAssertEqual(controller.syncAnnotationsButton.isEnabled, true)
        XCTAssertNoThrow(controller.syncAnnotationsButton.sendActions(for: .primaryActionTriggered))
    }

    func testAnnotationSaveStateChanges() {
        controller.view.layoutIfNeeded()
        controller.annotationSaveStateChanges(saving: true)
        XCTAssertEqual(controller.syncAnnotationsButton.isEnabled, false)
        XCTAssertEqual(controller.syncAnnotationsButton.title(for: .normal), "Saving...")
        controller.annotationSaveStateChanges(saving: false)
        XCTAssertEqual(controller.syncAnnotationsButton.title(for: .normal), "All annotations saved.")
    }
}
