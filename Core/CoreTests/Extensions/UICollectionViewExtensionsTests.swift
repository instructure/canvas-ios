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
import UIKit
@testable import Core

class UICollectionViewExtensionsTests: XCTestCase {
    class Cell: UICollectionViewCell {}
    class View: UICollectionReusableView {}
    func testDequeue() {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        view.register(View.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "View")

        XCTAssertNoThrow(view.dequeue(for: IndexPath(row: 0, section: 0)) as Cell)
        XCTAssertNoThrow(view.dequeue(View.self, ofKind: UICollectionView.elementKindSectionHeader, for: IndexPath(row: 0, section: 0)))
    }
}
