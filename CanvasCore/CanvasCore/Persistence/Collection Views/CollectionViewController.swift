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

import ReactiveSwift


public protocol CollectionViewCellViewModel {
    static func viewDidLoad(_ collectionView: UICollectionView)
    static var layout: UICollectionViewLayout { get }

    func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
}

open class CollectionViewController: UICollectionViewController {
    open var dataSource: CollectionViewDataSource! {
        didSet {
            if isViewLoaded {
                dataSource?.viewDidLoad(self)
            }
        }
    }

    open var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            setupRefreshingObservation()
        }
    }
    
    private var refreshDisposable: Disposable? = nil

    open var didSelectItemAtIndexPath: ((IndexPath)->())? = nil

    open var emptyView: UIView? {
        didSet {
            self.updateEmptyView()
        }
    }

    public init() {
        super.init(collectionViewLayout: PrettyCardsLayout())
    }
    
    deinit {
        refreshDisposable?.dispose()
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

    fileprivate func setupRefreshingObservation() {
        let composite = CompositeDisposable()
        refreshDisposable?.dispose()
        refreshDisposable = composite
        
        composite += refresher?.refreshingBegan.observeValues { [weak self] in
            self?.updateEmptyView()
        }
        composite += refresher?.refreshingCompleted.observeValues { [weak self] error in
            self?.updateEmptyView()
            ErrorReporter.reportError(error, from: self)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        dataSource?.viewDidLoad(self)
        refresher?.makeRefreshable(self)
        updateEmptyView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresher?.refresh(false)
    }

    // MARK: delegate
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAtIndexPath?(indexPath)
    }

    // MARK: Empty View Handling
    fileprivate func updateEmptyView() {
        guard let emptyView = emptyView, let collectionView = collectionView else {
            return
        }

        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = collectionView.numberOfSections == 0 && !isRefreshing
        if emptyVisible {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = UIView()
        }
    }
}

