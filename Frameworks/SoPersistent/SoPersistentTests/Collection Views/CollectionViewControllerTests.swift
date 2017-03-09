//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import Foundation
import SoAutomated
import SoLazy
@testable import SoPersistent
import SoLazy

@available(*, deprecated, message: "bdd syntactic sugar is deprecated, use Quick instead")
public func context(_ name: String, f: ()->Void) {
    f()
}

@available(*, deprecated, message: "bdd syntactic sugar is deprecated, use Quick instead")
public func it(_ behavior: String, f: ()->Void) {
    f()
}

@available(*, deprecated, message: "bdd syntactic sugar is deprecated, use Quick instead")
public func describe(_ description: String, f: ()->Void) {
    f()
}

class CollectionViewControllerTests: XCTestCase {

    func testDescribeCollectionViewController() {
        let refresher = SimpleRefresher()
        let dataSource = SimpleCollectionViewDataSource()
        let vc = CollectionViewController(dataSource: dataSource, refresher: refresher)

        describe("selecting an item") {
            it("has a hook for when an item is selected") {
                var indexPath: IndexPath?
                vc.didSelectItemAtIndexPath = { indexPath = $0 }
                let collectionView = vc.collectionView!

                let delegate = vc as UICollectionViewDelegate

                delegate.collectionView?(collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))

                XCTAssertNotNil(indexPath)
                XCTAssertEqual(IndexPath(row: 0, section: 0), indexPath)
            }
        }

        describe("refresher") {
            it("makes refresher when set") {
                refresher.makeRefreshableWasCalled = false
                vc.refresher = refresher
                XCTAssert(refresher.makeRefreshableWasCalled)
            }

            it("sets refreshCompleted to one that presents the error") {
                var presented = false
                ErrorReporter.setErrorHandler { _ in
                    presented = true
                }
                let error = NSError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                vc.refresher = refresher
                refresher.refreshingCompletedObserver.send(value: error)

                XCTAssert(presented)
            }

            it("sets refreshCompleted to one that presents the error on init") {
                var presented = false
                ErrorReporter.setErrorHandler { _ in
                    presented = true
                }
                let error = NSError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                let vc = CollectionViewController(dataSource: dataSource, refresher: refresher)
                vc.refresher = refresher
                refresher.refreshingCompletedObserver.send(value: error)

                XCTAssert(presented)
            }
        }
    }
}
