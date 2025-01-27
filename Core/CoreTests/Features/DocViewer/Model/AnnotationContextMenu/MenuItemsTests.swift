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

@testable import Core
import TestsFoundation
import XCTest

class MenuItemsTests: XCTestCase {

    func testStyleMenu() {
        let mockPageView = MockPDFPageView()
        let annotation = DocViewerInkAnnotation()
        let testee = UIAction.style(annotation: annotation, pageView: mockPageView)

        testee.performWithSender(nil, target: nil)

        XCTAssertEqual(testee.title, "Style")
        XCTAssertNil(testee.image)
        XCTAssertEqual(mockPageView.presentedInspectorForAnnotations, [annotation])
    }

    func testDeleteMenu() {
        let mockDocument = MockPDFDocument()
        let annotation = DocViewerInkAnnotation()
        let testee = UIAction.deleteAnnotation(document: mockDocument, annotation: annotation)

        testee.performWithSender(nil, target: nil)

        XCTAssertEqual(testee.title, "Remove")
        XCTAssertEqual(testee.image, .trashLine)
        XCTAssertEqual(mockDocument.removed, [annotation])
    }

    func testShowCommentsMenu() {
        // MARK: - GIVEN
        let mockRouter = TestRouter()
        let mockDocument = MockPDFDocument()
        let annotation = DocViewerInkAnnotation()
        let container = UIViewController()
        let metadata = APIDocViewerAnnotationsMetadata.make()
        let comments = [DocViewerCommentReplyAnnotation(contents: "test")]
        let mockAnnotationProvider = MockDocViewerAnnotationProvider(isAnnotatingDisabledInApp: false,
                                                                     isAPIEnabledAnnotations: true)
        mockAnnotationProvider.mockGetRepliesToAnnotationMethodResult = comments
        let testee = UIAction.showComments(annotation: annotation,
                                           annotationMetadata: metadata,
                                           annotationProvider: mockAnnotationProvider,
                                           document: mockDocument,
                                           container: container,
                                           router: mockRouter)

        // MARK: - WHEN
        testee.performWithSender(nil, target: nil)

        // MARK: - THEN
        XCTAssertEqual(testee.title, "Comments")
        XCTAssertNil(testee.image)

        guard let routeoptions = mockRouter.viewControllerCalls.last else {
            return XCTFail()
        }

        XCTAssertEqual(routeoptions.1, container)
        XCTAssertEqual(routeoptions.2, .modal(embedInNav: true))

        guard let commentsViewController = routeoptions.0 as? CommentListViewController else {
            return XCTFail()
        }

        XCTAssertEqual(commentsViewController.comments, comments)
        XCTAssertEqual(commentsViewController.annotation, annotation)
    }
}
