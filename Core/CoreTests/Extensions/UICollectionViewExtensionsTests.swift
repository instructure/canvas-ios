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
import UIKit
@testable import Core

class UICollectionViewExtensionsTests: XCTestCase {
    class Cell: UICollectionViewCell {}
    class View: UICollectionReusableView {}
    func testDequeue() {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        view.register(View.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "View")
        XCTAssertNoThrow(view.dequeue(Cell.self, for: IndexPath(row: 0, section: 0)))
        XCTAssertNoThrow(view.dequeue(View.self, ofKind: UICollectionView.elementKindSectionHeader, for: IndexPath(row: 0, section: 0)))
    }
}
