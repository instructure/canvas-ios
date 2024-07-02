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
        bgColor: String? = "transparent",
        icon: String? = nil,
        contents: String? = nil,
        inreplyto: String? = nil,
        coords: [[[Double]]]? = nil,
        rect: [[Double]]? = [[0, 0], [1, 1]],
        font: String? = nil,
        inklist: APIDocViewerInklist? = nil,
        width: Double? = 0
    ) -> APIDocViewerAnnotation {
        return APIDocViewerAnnotation(
            id: id, document_id: document_id, user_id: user_id, user_name: user_name, page: page,
            created_at: created_at, modified_at: modified_at, deleted: deleted, deleted_at: deleted_at,
            deleted_by: deleted_by, deleted_by_id: deleted_by_id, type: type, color: color, bgColor: bgColor, icon: icon,
            contents: contents, inreplyto: inreplyto, coords: coords, rect: rect, font: font,
            inklist: inklist, width: width
        )
    }

    func testHighlight() {
        let apiAnnotation = model(type: .highlight, coords: [[[0, 0], [1, 0], [0, 1], [1, 1]]])
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        annotation?.hasReplies = true
        XCTAssert(annotation is HighlightAnnotation)
        XCTAssert(annotation is DocViewerHighlightAnnotation)
        XCTAssertNoThrow(UIGraphicsImageRenderer(size: annotation!.boundingBox.size).image { context in
            annotation?.draw(context: context.cgContext, options: nil)
        })
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.rects, [ CGRect(x: 0, y: 0, width: 1, height: 1) ])
    }

    func testStrikeout() {
        let apiAnnotation = model(type: .strikeout, color: nil, coords: [[[0, 0], [1, 0], [0, 1], [1, 1]]])
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is StrikeOutAnnotation)
        XCTAssert(annotation is DocViewerStrikeOutAnnotation)
        XCTAssertNoThrow(UIGraphicsImageRenderer(size: annotation!.boundingBox.size).image { context in
            annotation?.draw(context: context.cgContext, options: nil)
        })
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.rects, [ CGRect(x: 0, y: 0, width: 1, height: 1) ])
        XCTAssertNil(annotation?.color)
    }

    func testFreetext() {
        let apiAnnotation = model(type: .freetext, bgColor: "#ffffff", contents: "freetext", font: "38pt Lato-Regular")
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is FreeTextAnnotation)
        XCTAssert(annotation is DocViewerFreeTextAnnotation)
        XCTAssertNoThrow(UIGraphicsImageRenderer(size: annotation!.boundingBox.size).image { context in
            annotation?.draw(context: context.cgContext, options: nil)
        })
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.contents, "freetext")
        XCTAssertEqual(annotation?.fontName, "Lato-Regular")
        XCTAssertEqual(annotation?.fontSize, 38 * 0.85)

        let apiEmpty = model(type: .freetext, contents: nil, font: nil)
        guard let empty = Annotation.from(apiEmpty, metadata: metadata) else { return XCTFail() }
        XCTAssertEqual(empty.contents, "")
        XCTAssertEqual(empty.fontName, "Lato-Regular")
        XCTAssertEqual(empty.fontSize, 14 * 0.85)
        XCTAssertNil(empty.fillColor)
    }

    func testPoint() {
        let apiAnnotation = model(type: .text, icon: "Comment")
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is DocViewerPointAnnotation)
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
    }

    func testCommentReply() {
        let apiAnnotation = model(type: .commentReply, contents: "comment", inreplyto: "5")
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is DocViewerCommentReplyAnnotation)

        // Reply comment annotations shouldn't have any dimensions otherwise they won't render on web
        var expectedAPIAnnotation = apiAnnotation
        expectedAPIAnnotation.width = nil
        expectedAPIAnnotation.rect = nil

        XCTAssertEqual(annotation?.apiAnnotation(), expectedAPIAnnotation)
        XCTAssertEqual(annotation?.contents, "comment")
        XCTAssertEqual((annotation as! DocViewerCommentReplyAnnotation).inReplyToName, "5")
    }

    func testInk() {
        let apiAnnotation = model(type: .ink, color: "#00ffff", inklist: APIDocViewerInklist(gestures: [
            [APIDocViewerInkPoint(x: 1, y: 1, width: 1, opacity: 1), APIDocViewerInkPoint(x: 10, y: 10, width: 3, opacity: 1)],
            [APIDocViewerInkPoint(x: 5, y: 5, width: 1, opacity: 1), APIDocViewerInkPoint(x: 10, y: 10, width: 2, opacity: 1)]
        ]), width: 4.5)
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is InkAnnotation)
        XCTAssert(annotation is DocViewerInkAnnotation)
        XCTAssertNoThrow(UIGraphicsImageRenderer(size: annotation!.boundingBox.size).image { context in
            annotation?.draw(context: context.cgContext, options: nil)
        })
        XCTAssertEqual(annotation?.apiAnnotation()?.type, .ink) // float precision makes testing full equality fail
        XCTAssertEqual(annotation?.color?.hexString, "#00ffff")
        let lines = (annotation as! InkAnnotation).lines!
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines[0][0].location, CGPoint(x: 1, y: 1))
        XCTAssertEqual(lines[0][1].location, CGPoint(x: 10, y: 10))
        XCTAssertEqual(lines[1][0].location, CGPoint(x: 5, y: 5))
        XCTAssertEqual(lines[1][1].location, CGPoint(x: 10, y: 10))
        XCTAssertEqual(annotation?.lineWidth, 4.5)
    }

    func testSquare() {
        let apiAnnotation = model(type: .square, width: 2)
        let annotation = Annotation.from(apiAnnotation, metadata: metadata)
        annotation?.lastModified = nil
        XCTAssert(annotation is SquareAnnotation)
        XCTAssert(annotation is DocViewerSquareAnnotation)
        XCTAssertNoThrow(UIGraphicsImageRenderer(size: annotation!.boundingBox.size).image { context in
            annotation?.draw(context: context.cgContext, options: nil)
        })
        XCTAssertEqual(annotation?.apiAnnotation(), apiAnnotation)
        XCTAssertEqual(annotation?.lineWidth, 2)
    }

    func testIsEmpty() {
        XCTAssertTrue(FreeTextAnnotation(contents: "").isEmpty)
        XCTAssertTrue(DocViewerCommentReplyAnnotation(contents: "").isEmpty)
        XCTAssertFalse(FreeTextAnnotation(contents: "a").isEmpty)
        XCTAssertFalse(DocViewerCommentReplyAnnotation(contents: "b").isEmpty)
        XCTAssertFalse(SquareAnnotation().isEmpty)
    }

    func testSimplify() {
        XCTAssertEqual(simplify([]), [])
        let points = [
            APIDocViewerInkPoint(x: 0, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 10, y: 2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 50, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 90, y: -2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 100, y: 0, width: nil, opacity: nil)
        ]
        XCTAssertEqual(simplify(points, within: 1.99), [
            APIDocViewerInkPoint(x: 0, y: 0, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 10, y: 2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 90, y: -2, width: nil, opacity: nil),
            APIDocViewerInkPoint(x: 100, y: 0, width: nil, opacity: nil)
        ])
    }
}
