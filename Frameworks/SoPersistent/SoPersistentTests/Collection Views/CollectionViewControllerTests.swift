//
//  CollectionViewControllerTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoAutomated
@testable import SoPersistent
import SoLazy

@available(*, deprecated, message="bdd syntactic sugar is deprecated, use Quick instead")
public func context(name: String, f: ()->Void) {
    f()
}

@available(*, deprecated, message="bdd syntactic sugar is deprecated, use Quick instead")
public func it(behavior: String, f: ()->Void) {
    f()
}

@available(*, deprecated, message="bdd syntactic sugar is deprecated, use Quick instead")
public func describe(description: String, f: ()->Void) {
    f()
}

class CollectionViewControllerTests: XCTestCase {

    func testDescribeCollectionViewController() {
        let refresher = SimpleRefresher()
        let dataSource = SimpleCollectionViewDataSource()
        let vc = CollectionViewController(dataSource: dataSource, refresher: refresher)

        describe("selecting an item") {
            it("has a hook for when an item is selected") {
                var indexPath: NSIndexPath?
                vc.didSelectItemAtIndexPath = { indexPath = $0 }
                let collectionView = vc.collectionView!

                vc.collectionView(collectionView, didSelectItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                XCTAssertNotNil(indexPath)
                XCTAssertEqual(NSIndexPath(forRow: 0, inSection: 0), indexPath)
            }
        }

        describe("refresher") {
            it("makes refresher when set") {
                refresher.makeRefreshableWasCalled = false
                vc.refresher = refresher
                XCTAssert(refresher.makeRefreshableWasCalled)
            }

            it("sets refreshCompleted to one that presents the error") {
                class RefreshError: NSError {
                    var presented = false
                    private override func presentAlertFromViewController(viewController: UIViewController, alertDismissed: (()->())? = nil, reportError: (()->())? = nil) {
                        presented = true
                    }
                }
                let error = RefreshError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                vc.refresher = refresher
                refresher.refreshingCompletedObserver.sendNext(error)

                XCTAssert(error.presented)
            }

            it("sets refreshCompleted to one that presents the error on init") {
                class RefreshError: NSError {
                    var presented = false
                    private override func presentAlertFromViewController(viewController: UIViewController, alertDismissed: (()->())? = nil, reportError: (()->())? = nil) {
                        presented = true
                    }
                }
                let error = RefreshError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                let vc = CollectionViewController(dataSource: dataSource, refresher: refresher)
                vc.refresher = refresher
                refresher.refreshingCompletedObserver.sendNext(error)

                XCTAssert(error.presented)
            }
        }
    }
}
