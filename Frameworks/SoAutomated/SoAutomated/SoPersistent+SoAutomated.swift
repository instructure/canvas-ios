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
    
    

@testable import SoPersistent
import CoreData
import ReactiveSwift
import Result
import Nimble

open class ViewModelFactory<T>: TableViewCellViewModel {
    public typealias View = (T)->UITableViewCell

    let view: View
    let model: T

    open static func new(_ view: @escaping View) -> (T) -> ViewModelFactory<T> {
        return { model in
            return ViewModelFactory(model: model, view: view)
        }
    }

    open static var empty: (T)->ViewModelFactory<T> {
        let view: View = { _ in UITableViewCell(style: .default, reuseIdentifier: nil) }
        return { ViewModelFactory(model: $0, view: view) }
    }

    init(model: T, view: @escaping View) {
        self.model = model
        self.view = view
    }

    open static func tableViewDidLoad(_ tableView: UITableView) {}

    open func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return view(model)
    }
}

open class CollectionViewCellViewModelFactory<T>: CollectionViewCellViewModel {
    public typealias View = (UICollectionView, IndexPath, T)->UICollectionViewCell

    static var identifier: String {
        return "CollectionViewCell"
    }

    let view: View
    let model: T
    open static var layout: UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }

    open static func new(_ view: @escaping View) -> (T) -> CollectionViewCellViewModelFactory<T> {
        return { model in
            return CollectionViewCellViewModelFactory(model: model, view: view)
        }
    }

    open static var empty: (T)->CollectionViewCellViewModelFactory<T> {
        let view: View = { collectionView, indexPath, _ in
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) 
        }
        return { CollectionViewCellViewModelFactory(model: $0, view: view) }
    }

    init(model: T, view: @escaping View) {
        self.model = model
        self.view = view
    }

    open static func viewDidLoad(_ collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }

    open func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return view(collectionView, indexPath, model)
    }
}

open class EmptyRefresher: Refresher {
    open let cacheKey: String
    open let isRefreshing: Bool = false
    open let refreshControl = UIRefreshControl()

    open var refreshingBegan: Signal<(), NoError>
    var refreshingBeganObserver: Observer<(), NoError>
    open var refreshingCompleted: Signal<NSError?, NoError>
    var refreshingCompletedObserver: Observer<NSError?, NoError>

    public init(cacheKey: String = "empty") {
        self.cacheKey = cacheKey
        let (beganSignal, beganObserver) = Signal<(), NoError>.pipe()
        self.refreshingBegan = beganSignal.observe(on: UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, NoError>.pipe()
        self.refreshingCompleted = completedSignal.observe(on: UIScheduler())
        self.refreshingCompletedObserver = completedObserver
    }

    open func makeRefreshable(_ viewController: UIViewController) {
        // no-op
    }

    open func refresh(_ forced: Bool) {
        refreshingCompletedObserver.send(value: nil)
    }

    open func cancel() {
        // no-op
    }

    open func safeCopy() -> Refresher? {
        return EmptyRefresher()
    }
}
