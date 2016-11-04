
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
import ReactiveCocoa
import Result
import Nimble

public class ViewModelFactory<T>: TableViewCellViewModel {
    public typealias View = T->UITableViewCell

    let view: View
    let model: T

    public static func new(view: View) -> T -> ViewModelFactory<T> {
        return { model in
            return ViewModelFactory(model: model, view: view)
        }
    }

    public static var empty: T->ViewModelFactory<T> {
        let view: View = { _ in UITableViewCell(style: .Default, reuseIdentifier: nil) }
        return { ViewModelFactory(model: $0, view: view) }
    }

    init(model: T, view: View) {
        self.model = model
        self.view = view
    }

    public static func tableViewDidLoad(tableView: UITableView) {}

    public func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return view(model)
    }
}

public class CollectionViewCellViewModelFactory<T>: CollectionViewCellViewModel {
    public typealias View = (UICollectionView, NSIndexPath, T)->UICollectionViewCell

    static var identifier: String {
        return "CollectionViewCell"
    }

    let view: View
    let model: T
    public static var layout: UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }

    public static func new(view: View) -> T -> CollectionViewCellViewModelFactory<T> {
        return { model in
            return CollectionViewCellViewModelFactory(model: model, view: view)
        }
    }

    public static var empty: T->CollectionViewCellViewModelFactory<T> {
        let view: View = { collectionView, indexPath, _ in
            collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) 
        }
        return { CollectionViewCellViewModelFactory(model: $0, view: view) }
    }

    init(model: T, view: View) {
        self.model = model
        self.view = view
    }

    public static func viewDidLoad(collectionView: UICollectionView) {
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }

    public func cellForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        return view(collectionView, indexPath, model)
    }
}

public class EmptyRefresher: Refresher {
    public let cacheKey: String = "empty"
    public let isRefreshing: Bool = false
    public let refreshControl = UIRefreshControl()

    public var refreshingBegan: Signal<(), NoError>
    var refreshingBeganObserver: Observer<(), NoError>
    public var refreshingCompleted: Signal<NSError?, NoError>
    var refreshingCompletedObserver: Observer<NSError?, NoError>

    public init() {
        let (beganSignal, beganObserver) = Signal<(), NoError>.pipe()
        self.refreshingBegan = beganSignal.observeOn(UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, NoError>.pipe()
        self.refreshingCompleted = completedSignal.observeOn(UIScheduler())
        self.refreshingCompletedObserver = completedObserver
    }

    public func makeRefreshable(viewController: UIViewController) {
        // no-op
    }

    public func refresh(forced: Bool) {
        refreshingCompletedObserver.sendNext(nil)
    }

    public func cancel() {
        // no-op
    }

    public func safeCopy() -> Refresher? {
        return EmptyRefresher()
    }
}
