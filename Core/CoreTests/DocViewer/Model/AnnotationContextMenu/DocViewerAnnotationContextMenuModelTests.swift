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

import XCTest
@testable import Core
import PSPDFKit
import PSPDFKitUI

class DocViewerAnnotationContextMenuModelTests: CoreTestCase {
    private let editTextAction = UIAction(title: "Edit Text",
                                          identifier: .PSPDFKit.editFreeText) { _ in }
    private let deleteAction = UIAction(title: "Default",
                                         identifier: .PSPDFKit.delete) { _ in }
    private let pageView = PDFPageView(frame: .zero)
    private let container = UIViewController()

    private func makeDocViewerMetadata(isAPIAnnotatable: Bool) -> APIDocViewerMetadata {
        APIDocViewerMetadata.make(annotations: .make(enabled: isAPIAnnotatable))
    }

    private func makeTestee(isAnnotatingEnabledInApp: Bool,
                            isAPIEnabledAnnotations: Bool)
    -> DocViewerAnnotationContextMenuModel {
        let mockAnnotationProvider = MockDocViewerAnnotationProvider(isAnnotatingDisabledInApp: !isAnnotatingEnabledInApp,
                                                                     isAPIEnabledAnnotations: isAPIEnabledAnnotations)
        return DocViewerAnnotationContextMenuModel(isAnnotationEnabled: isAnnotatingEnabledInApp,
                                                   metadata: makeDocViewerMetadata(isAPIAnnotatable: isAPIEnabledAnnotations),
                                                   document: mockAnnotationProvider.document,
                                                   annotationProvider: mockAnnotationProvider,
                                                   router: router)
    }

    // MARK: - Not Annotatable Document

    func testMenuOnNotAnnotatableDocumentWithACommentedAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: false, isAPIEnabledAnnotations: false)
        let annotation = DocViewerInkAnnotation()
        annotation.hasReplies = true
        let menu = testee.menu(for: [annotation],
                               pageView: pageView,
                               basedOn: UIMenu(children: [deleteAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 1)
        XCTAssertEqual(menu[0].title, "Comments")
    }

    func testMenuOnNotAnnotatableDocumentWithNotCommentedAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: false, isAPIEnabledAnnotations: false)
        let menu = testee.menu(for: [DocViewerInkAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [deleteAction]),
                               container: container)
            .children
        XCTAssertTrue(menu.isEmpty)
    }

    // MARK: - Annotatable Document

    func testMenuOnAnnotatableDocumentWithAppAnnotatingOff() {
        let testee = makeTestee(isAnnotatingEnabledInApp: false, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerInkAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [deleteAction]),
                               container: container)
            .children
        XCTAssertTrue(menu.isEmpty)
    }

    func testMenuForMultipleAnnotations() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [
                                        DocViewerInkAnnotation(),
                                        DocViewerInkAnnotation()
                                    ],
                               pageView: pageView,
                               basedOn: UIMenu(children: [deleteAction]),
                               container: container)
            .children
        XCTAssertTrue(menu.isEmpty)
    }

    func testMenuForFileAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [MockFileTextAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [deleteAction]),
                               container: container)
            .children
        XCTAssertTrue(menu.isEmpty)
    }

    // MARK: Annotation Types

    func testMenuForPinAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerPointAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 3)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Style")
        XCTAssertEqual(menu[2].title, "Remove")
    }

    func testMenuForTextHighlightAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerHighlightAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 2)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Remove")
    }

    func testMenuForTextAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerFreeTextAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 4)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Style")
        XCTAssertEqual(menu[2].title, "Edit Text")
        XCTAssertEqual(menu[3].title, "Remove")
    }

    func testMenuForTextAnnotationByPSPDFKit() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [FreeTextAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 4)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Style")
        XCTAssertEqual(menu[2].title, "Edit Text")
        XCTAssertEqual(menu[3].title, "Remove")
    }

    func testMenuForTextStrikeoutAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerStrikeOutAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 2)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Remove")
    }

    func testMenuForFreeDrawAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerInkAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 3)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Style")
        XCTAssertEqual(menu[2].title, "Remove")
    }

    func testMenuForSquareAnnotation() {
        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        let menu = testee.menu(for: [DocViewerSquareAnnotation()],
                               pageView: pageView,
                               basedOn: UIMenu(children: [editTextAction]),
                               container: container)
            .children
        XCTAssertEqual(menu.count, 3)
        XCTAssertEqual(menu[0].title, "Comments")
        XCTAssertEqual(menu[1].title, "Style")
        XCTAssertEqual(menu[2].title, "Remove")
    }

    func testDisablesRotating() {
        let resizableView = ResizableView()
        let annotationView = FreeTextAnnotationView()
        annotationView.resizableView = resizableView
        let pageView = MockPDFPageView(frame: .zero)
        pageView.mockAnnotationView = annotationView
        XCTAssertTrue(resizableView.allowRotating)

        let testee = makeTestee(isAnnotatingEnabledInApp: true, isAPIEnabledAnnotations: true)
        _ = testee.menu(for: [FreeTextAnnotation(contents: "dont rotate")],
                        pageView: pageView,
                        basedOn: UIMenu(children: [editTextAction]),
                        container: container)
        XCTAssertFalse(resizableView.allowRotating)
    }
}
