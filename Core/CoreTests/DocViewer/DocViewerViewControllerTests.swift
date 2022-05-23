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
        controller.isAnnotatable = true
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
    lazy var session: MockSession = {
        let session = MockSession { [weak self] in
            self?.controller.sessionIsReady()
        }
        session.metadata = .make() // to ensure metadata allows annotations
        return session
    }()

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
        XCTAssertEqual(navigationItem.rightBarButtonItems, nil)
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
        XCTAssertEqual(navigationItem.rightBarButtonItems?.count, 2)
    }

    func testLoadFallback() {
        session.localURL = url
        controller.previewURL = nil
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.pdf.document?.fileURL, url)
        XCTAssertEqual(navigationItem.rightBarButtonItems?.count, 2)
    }

    func testLoadFallbackRepeat() {
        session.error = APIDocViewerError.noData
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(router.presented)
        XCTAssertEqual(controller.fallbackUsed, true)
        XCTAssertEqual(navigationItem.rightBarButtonItems, nil)

        session.error = APIDocViewerError.noData
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.pdf.document)
        XCTAssertEqual(controller.fallbackUsed, true)
    }

    func testShouldShowForSelectedText() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test", block: {}),
            MenuItem(title: "test1", block: {}, identifier: TextMenu.annotationMenuHighlight.rawValue),
        ]
        controller.view.layoutIfNeeded()
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            forSelectedText: "",
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?[0], menuItems[0])
    }

    func testAnnotationContextMenuForNonAnnotatableDocuments() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test", block: {}),
        ]
        controller.isAnnotatable = false
        controller.view.layoutIfNeeded()
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
    }

    func testAnnotationContextMenuForAnnotationDisabledDocuments() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test", block: {}),
        ]
        controller.isAnnotatable = true
        controller.metadata = APIDocViewerMetadata.make(annotations: .make(enabled: false))
        controller.view.layoutIfNeeded()
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
    }

    func testAnnotationContextMenuForFileAnnotations() {
        // Setup view controller to load a local pdf with one annotation in it
        let url = Bundle(for: Self.self).url(forResource: "file_annotation_from_ios", withExtension: "pdf")!
        let controller: DocViewerViewController = {
            let controller = DocViewerViewController.create(
                filename: "file_annotation_from_ios.pdf",
                previewURL: url, fallbackURL: url
            )
            controller.session = {
                let session = MockSession { controller.sessionIsReady() }
                session.annotations = []
                session.sessionID = "abcd"
                session.sessionURL = URL(string: "session")
                session.localURL = url
                session.metadata = .make(annotations: .make(enabled: true))
                return session
            }()

            controller.isAnnotatable = true
            return controller
        }()
        controller.view.layoutIfNeeded()

        // Get a reference to that single annotation so we can call the delegate method with it
        let fileAnnotation = controller.annotationProvider!.annotationsForPage(at: 0)!.first!
        XCTAssertTrue(fileAnnotation.isFileAnnotation)
        let menuItems: [MenuItem] = [
            MenuItem(title: "test", block: {}),
        ]

        // Call the delegate method with the file annotation and test if it returns no menu items
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [fileAnnotation],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
    }

    func testAnnotationContextMenuForMultipleAnnotations() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test1", block: {}),
            MenuItem(title: "test2", block: {}),
        ]
        controller.isAnnotatable = true
        controller.metadata = APIDocViewerMetadata.make(annotations: .make(enabled: true))
        controller.view.layoutIfNeeded()

        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [Annotation.from(.make(), metadata: .make())!, Annotation.from(.make(), metadata: .make())!],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].title, "test1")
        XCTAssertEqual(results[1].title, "test2")
    }

    func testAnnotationContextMenuForMultipleAnnotationsWhenAnnotationDisabled() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test1", block: {}),
            MenuItem(title: "test2", block: {}),
        ]
        controller.isAnnotatable = false
        controller.metadata = APIDocViewerMetadata.make(annotations: .make(enabled: true))
        controller.view.layoutIfNeeded()

        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [Annotation.from(.make(), metadata: .make())!, Annotation.from(.make(), metadata: .make())!],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
    }

    func testAnnotationContextMenuForSingleAnnotationWithoutCommentsWhenAnnotationDisabled() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test1", block: {}),
            MenuItem(title: "test2", block: {}),
        ]
        controller.isAnnotatable = false
        controller.metadata = APIDocViewerMetadata.make(annotations: .make(enabled: true))
        controller.view.layoutIfNeeded()

        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [Annotation.from(.make(), metadata: .make())!],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
    }

    func testAnnotationContextMenuForSingleAnnotationWithCommentWhenAnnotationDisabled() {
        let menuItems: [MenuItem] = [
            MenuItem(title: "test1", block: {}),
            MenuItem(title: "test2", block: {}),
        ]
        controller.isAnnotatable = false
        controller.metadata = APIDocViewerMetadata.make(annotations: .make(enabled: true))
        controller.view.layoutIfNeeded()

        let annotation = Annotation.from(.make(), metadata: .make())!
        annotation.hasReplies = true

        let results = controller.pdf.delegate?.pdfViewController?(
            PDFViewController(document: Document(url: url)),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [annotation],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        guard let results = results else { XCTFail("Nil array received"); return }

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, NSLocalizedString("Comments", bundle: .core, comment: ""))
    }

    class MockPDFDocument: Document {
        var added: [Annotation]?
        override func add(annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> Bool {
            added = annotations
            return false
        }

        var removed: [Annotation]?
        override func remove(annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> Bool {
            removed = annotations
            return false
        }
    }

    class MockPDFPageView: PDFPageView {
        var annotationView: (UIView & AnnotationPresenting)?
        override func annotationView(for annotation: Annotation) -> (UIView & AnnotationPresenting)? {
            return annotationView
        }
    }

    func testShouldShowForNoAnnotations() {
        let menuItems = [
            MenuItem(title: "test", block: {}),
            MenuItem(title: "", block: {}, identifier: TextMenu.annotationMenuOpacity.rawValue),
        ]
        // mock metadata because sessionIsReady() loads the fallback and not the pdf
        controller.metadata = .make(annotations: .make())
        controller.view.layoutIfNeeded()
        environment.app = .teacher
        var results = controller.pdf.delegate?.pdfViewController?(
            PDFViewController(document: Document(url: url)),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: nil,
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        XCTAssertEqual(results, [ menuItems[0] ])

        environment.app = .student
        results = controller.pdf.delegate?.pdfViewController?(
            PDFViewController(document: Document(url: url)),
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: nil,
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        XCTAssertEqual(results, [])
    }

    func testShouldShowForAnnotations() {
        let menuItems = [
            MenuItem(title: "test", block: {}),
            MenuItem(title: "opacity", block: {}, identifier: TextMenu.annotationMenuOpacity.rawValue),
            MenuItem(title: "inspector", block: {}, identifier: TextMenu.annotationMenuInspector.rawValue),
        ]
        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        let viewController = PDFViewController(document: MockPDFDocument(url: url))
        let annotation = NoteAnnotation(contents: "note")
        annotation.isEditable = true
        let results = controller.pdf.delegate?.pdfViewController?(
            viewController,
            shouldShow: menuItems,
            atSuggestedTargetRect: .zero,
            for: [annotation],
            in: .zero,
            on: PDFPageView(frame: .zero)
        )
        XCTAssertEqual(results?[0].title, "Comments")
        XCTAssertEqual(results?[1].title, "test")
        XCTAssertEqual(results?[2].title, "Style")
        XCTAssertEqual(results?[3].identifier, TextMenu.annotationMenuRemove.rawValue)

        results?[0].performBlock()
        XCTAssert(router.presented is CommentListViewController)

        results?[3].performBlock()
        XCTAssertEqual((viewController.document as? MockPDFDocument)?.removed, [annotation])
    }

    func testShouldShowForAnnotationsDontAllowRotating() {
        let menuItems = [
            MenuItem(title: "test", block: {}),
            MenuItem(title: "opacity", block: {}, identifier: TextMenu.annotationMenuOpacity.rawValue),
            MenuItem(title: "inspector", block: {}, identifier: TextMenu.annotationMenuInspector.rawValue),
        ]
        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        let viewController = PDFViewController(document: MockPDFDocument(url: url))
        let annotation = FreeTextAnnotation(contents: "text")
        let pageView = MockPDFPageView(frame: .zero)
        let annotationView = FreeTextAnnotationView()
        let resizableView = ResizableView()
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
        XCTAssertFalse(controller.pdfViewController(PDFViewController(), shouldShow: StampViewController(), animated: true))
        XCTAssertTrue(controller.pdfViewController(PDFViewController(), shouldShow: UIViewController(), animated: true))
    }

    func testCreatePinCommentAnnotationGesture() {
        XCTAssertEqual(controller.gestureRecognizerShouldBegin(UITapGestureRecognizer()), false)

        let document = MockPDFDocument(url: url)
        controller.pdf.document = document
        controller.pdf.annotationStateManager.state = .stamp

        controller.view.layoutIfNeeded()
        controller.metadata = APIDocViewerMetadata.make()
        XCTAssertEqual(controller.gestureRecognizerShouldBegin(UITapGestureRecognizer()), true)
        controller.createCommentPinAnnotation(pageView: PDFPageView(frame: .zero), at: .zero)
        XCTAssert(router.presented is CommentListViewController)
        XCTAssertEqual((controller.pdf.document as? MockPDFDocument)?.added?.count, 1)
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
