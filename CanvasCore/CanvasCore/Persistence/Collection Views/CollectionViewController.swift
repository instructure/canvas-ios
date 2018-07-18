//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

