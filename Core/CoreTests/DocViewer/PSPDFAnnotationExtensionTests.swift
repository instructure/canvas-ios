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
@testable import Core

class PSPDFAnnotationExtensionTests: XCTestCase {
    let metadata = APIDocViewerAnnotationsMetadata(
        enabled: true,
        user_id: "1",
        user_name: "a",
        permissions: .read
    )

    func model(
        type: APIDocViewerAnnotationType,
        id: String = "1",
        document_id: String? = nil,
        user_id: String? = "1",
        user_name: String = "a",
        page: UInt = 1,
        created_at: Date? = nil,
        modified_at: Date? = nil,
        deleted: Bool = true,
        deleted_at: Date? = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 23, minute: 59).date,
        deleted_by: String? = "b",
        deleted_by_id: String? = "2",
        color: String? = "#ffff00",
        icon: String? = nil,
        contents: String? = "",
        inreplyto: String? = nil,
        coords: [[[Double]]]? = nil,
        rect: [[Double]]? = [[0, 0], [1, 1]],
        font: String? = nil,
        inklist: APIDocViewerInklist? = nil,
        width: Double? = nil
    ) -> APIDocViewerAnnotation {
        return APIDocViewerAnnotation(
            id: id, document_id: document_id, user_id: user_id, user_name: user_name, page: page,
            created_at: created_at, modified_at: modified_at, deleted: deleted, deleted_at: deleted_at,
            deleted_by: deleted_by, deleted_by_id: deleted_by_id, type: type, color: color, icon: icon,
            contents: contents, inreplyto: inreplyto, coords: coords, rect: rect, font: font,
            inklist: inklist, width: width
        )
    }

    func testHighlight() {
        let apiAnnotation = model(type: .highlight, coords: [[[0, 0], [1, 1]]])
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is PSPDFHighlightAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.rects, [NSValue(cgRect: CGRect(x: 0, y: 0, width: 1, height: 1))])
    }

    func testStrikeout() {
        let apiAnnotation = model(type: .strikeout, color: nil, coords: [[[0, 0], [1, 1]]])
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is PSPDFStrikeOutAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.rects, [NSValue(cgRect: CGRect(x: 0, y: 0, width: 1, height: 1))])
        XCTAssertNil(annotation?.color)
    }

    func testFreetext() {
        let apiAnnotation = model(type: .freetext, contents: "freetext", font: "38pt Helvetica")
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is PSPDFFreeTextAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.contents, "freetext")
        XCTAssertEqual(annotation?.fontName, "Helvetica")
        XCTAssertEqual(annotation?.fontSize, 38)

        let apiEmpty = model(type: .freetext, contents: nil, font: nil)
        let empty = PSPDFAnnotation.from(apiEmpty, metadata: metadata)
        XCTAssertEqual(empty?.contents, "")
        XCTAssertEqual(empty?.fontName, "Verdana")
        XCTAssertEqual(empty?.fontSize, 14)
    }

    func testPoint() {
        let apiAnnotation = model(type: .text, icon: "Comment")
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is DocViewerPointAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
    }

    func testCommentReply() {
        let apiAnnotation = model(type: .commentReply, contents: "comment", inreplyto: "5")
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is DocViewerCommentReplyAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.contents, "comment")
        XCTAssertEqual((annotation as! DocViewerCommentReplyAnnotation).inReplyToName, "5")
    }

    func testInk() {
        let apiAnnotation = model(type: .ink, color: "#00ffff", inklist: APIDocViewerInklist(gestures: [
            [APIDocViewerInkPoint(x: 1, y: 1, width: 1, opacity: 1), APIDocViewerInkPoint(x: 10, y: 10, width: 3, opacity: 1)],
            [APIDocViewerInkPoint(x: 5, y: 5, width: 1, opacity: 1), APIDocViewerInkPoint(x: 10, y: 10, width: 2, opacity: 1)],
        ]))
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is PSPDFInkAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation()?.type, .ink) // float precision makes testing full equality fail
        XCTAssertEqual(annotation?.color?.hexString, "#00ffff")
        let lines = (annotation as! PSPDFInkAnnotation).lines!
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines[0][0].pspdf_drawingPointValue.intensity, 0.06)
        XCTAssertEqual(lines[0][1].pspdf_drawingPointValue.intensity, 1)
        XCTAssertEqual(lines[1][0].pspdf_drawingPointValue.intensity, 0.06)
        XCTAssertEqual(lines[1][1].pspdf_drawingPointValue.intensity, 0.53)
    }

    func testSquare() {
        let apiAnnotation = model(type: .square, width: 2)
        let annotation = PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is PSPDFSquareAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.lineWidth, 2)
    }

    func testIsEmpty() {
        XCTAssertTrue(PSPDFFreeTextAnnotation(contents: "").isEmpty)
        XCTAssertTrue(DocViewerCommentReplyAnnotation(contents: "").isEmpty)
        XCTAssertFalse(PSPDFFreeTextAnnotation(contents: "a").isEmpty)
        XCTAssertFalse(DocViewerCommentReplyAnnotation(contents: "b").isEmpty)
        XCTAssertFalse(PSPDFSquareAnnotation().isEmpty)
    }

    func testSimplify() {
        XCTAssertEqual(simplify([]), [])
        let points = [
            APIDocViewerInkPoint(x: 0, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 10, y: 2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 50, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 90, y: -2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 100, y: 0, width: nil, opacity: nil),
        ]
        XCTAssertEqual(simplify(points, within: 1.99), [
            APIDocViewerInkPoint(x: 0, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 10, y: 2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 90, y: -2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 100, y: 0, width: nil, opacity: nil),
        ])
    }
}
