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
import Combine
@testable import Core

class DocViewerViewControllerTests: CoreTestCase {
    lazy var controller: DocViewerViewController = {
        let controller = DocViewerViewController.create(
            filename: "instructure.pdf",
            previewURL: url, fallbackURL: url,
            navigationItem: navigationItem,
            offlineModeInteractor: MockOfflineModeInteractorDisabled()
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

    class MockOfflineModeInteractorDisabled: OfflineModeInteractor {
        func isFeatureFlagEnabled() -> Bool {
            false
        }

        func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
            Just(false).eraseToAnyPublisher()
        }

        func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
            Just(false).eraseToAnyPublisher()
        }

        func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
            Just(.connected(.wifi)).eraseToAnyPublisher()
        }

        func isOfflineModeEnabled() -> Bool { false }
    }

    class MockOfflineModeInteractorEnabled: OfflineModeInteractor {
        func isFeatureFlagEnabled() -> Bool {
            true
        }

        func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
            Just(true).eraseToAnyPublisher()
        }

        func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
            Just(true).eraseToAnyPublisher()
        }

        func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
            Just(.disconnected).eraseToAnyPublisher()
        }

        func isOfflineModeEnabled() -> Bool { true }
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

    func testLoadFallbackWhenOfflineModeIsEnabled() {
        controller = DocViewerViewController.create(
            filename: "instructure.pdf",
            previewURL: url, fallbackURL: url,
            navigationItem: navigationItem,
            offlineModeInteractor: MockOfflineModeInteractorEnabled()
        )
        controller.session = session
        controller.isAnnotatable = true

        session.error = APIDocViewerError.noData
        controller.view.layoutIfNeeded()
        XCTAssertNil(router.presented)
        XCTAssertEqual(controller.fallbackUsed, false)
        XCTAssertEqual(controller.loadingView.isHidden, true)
        XCTAssertEqual(navigationItem.rightBarButtonItems, nil)
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
        let menuItems: [UIAction] = [
            UIAction(title: "test", identifier: .PSPDFKit.editFreeText) { _ in },
        ]

        // Call the delegate method with the file annotation and test if it returns no menu items
        let results = controller.pdf.delegate?.pdfViewController?(
            controller.pdf,
            menuForAnnotations: [fileAnnotation],
            onPageView: PDFPageView(frame: .zero),
            appearance: .contextMenu,
            suggestedMenu: UIMenu(children: menuItems)
        )
        guard let results = results?.children else { XCTFail("Nil array received"); return }

        XCTAssertTrue(results.isEmpty)
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
