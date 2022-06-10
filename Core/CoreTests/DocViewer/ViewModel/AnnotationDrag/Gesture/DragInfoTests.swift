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
import PSPDFKit
import XCTest

class DragInfoTests: XCTestCase {
    typealias DragInfo = AnnotationDragGestureViewModel.DragInfo

    func testRemovesAnnotationCloneDelayed() {
        let annotation = InkAnnotation()
        let annotationClone = UIImageView()
        let pageView = UIView()
        pageView.addSubview(annotationClone)
        var testee: DragInfo? = DragInfo(dragPointWithinAnnotation: .zero, draggedAnnotation: annotation, annotationClone: annotationClone, pageView: pageView)
        XCTAssertEqual(annotationClone.superview, pageView)

        testee = nil

        XCTAssertNil(testee)
        XCTAssertEqual(annotationClone.superview, pageView)
        RunLoop.main.run(until: Date() + 1)
        XCTAssertNil(annotationClone.superview)
    }
}
