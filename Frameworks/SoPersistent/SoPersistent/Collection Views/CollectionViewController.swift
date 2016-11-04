
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
    
    

import UIKit
import SoPretty
import ReactiveCocoa
import SoLazy

public protocol CollectionViewCellViewModel {
    static func viewDidLoad(collectionView: UICollectionView)
    static var layout: UICollectionViewLayout { get }

    func cellForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell
}

public class CollectionViewController: UICollectionViewController {

    public static var defaultErrorHandler: (UIViewController, NSError) -> () = { vc, error in
        error.presentAlertFromViewController(vc)
    }

    public func handleError(error: NSError) {
        CollectionViewController.defaultErrorHandler(self, error)
    }

    public var dataSource: CollectionViewDataSource! {
        didSet {
            if isViewLoaded() {
                dataSource?.viewDidLoad(self)
            }
        }
    }

    public var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            setupRefreshingObservation()
        }
    }

    public var didSelectItemAtIndexPath: (NSIndexPath->())? = nil

    public var emptyView: UIView? {
        didSet {
            self.updateEmptyView()
        }
    }

    public init() {
        super.init(collectionViewLayout: PrettyCardsLayout())
    }

    public init(dataSource: CollectionViewDataSource, refresher: Refresher? = nil) {
        self.dataSource = dataSource
        self.refresher = refresher
        super.init(collectionViewLayout: dataSource.layout)
        setupRefreshingObservation()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupRefreshingObservation() {
        refresher?.refreshingBegan.observeNext { [weak self] in
            self?.updateEmptyView()
        }
        refresher?.refreshingCompleted.observeNext { [weak self] error in
            self?.updateEmptyView()
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
        dataSource?.viewDidLoad(self)
        refresher?.makeRefreshable(self)
        updateEmptyView()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresher?.refresh(false)
    }

    // MARK: delegate
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelectItemAtIndexPath?(indexPath)
    }

    // MARK: Empty View Handling
    private func updateEmptyView() {
        guard let emptyView = emptyView, collectionView = collectionView else {
            return
        }

        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = collectionView.numberOfSections() == 0 && !isRefreshing
        if emptyVisible {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = UIView()
        }
    }
}

