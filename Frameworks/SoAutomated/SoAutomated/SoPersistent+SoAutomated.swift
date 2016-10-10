//
//  SoPersistent+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 instructure. All rights reserved.
//

@testable import SoPersistent
import CoreData
import ReactiveCocoa
import Result

extension FetchedCollection where Model: NSFetchRequestResult {
    public var allObjects: [Object] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects as? [Object] ?? []
    }
}

extension ManagedObjectObserver {
    public func observe(object: NSManagedObject, change: ManagedObjectChange, withExpectation expectation: XCTestExpectation) -> Disposable? {
        return signal.observeNext { _change in
            if case change = _change.0 where _change.1 == object { expectation.fulfill() }
        }
    }
}

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

public func ==<U: Equatable>(a: CollectionUpdate<U>, b: CollectionUpdate<U>) -> Bool {
    switch (a, b) {
    case (.SectionInserted(let a), .SectionInserted(let b)) where a == b: return true
    case (.SectionDeleted(let a), .SectionDeleted(let b)) where a == b: return true
    case (.Inserted(let a, let pa), .Inserted(let b, let pb)) where a == b && pa == pb: return true
    case (.Updated(let a, let pa), .Updated(let b, let pb)) where a == b && pa == pb: return true
    case (.Moved(let a, let aa, let pa), .Moved(let b, let bb, let pb)) where a == b && aa == bb && pa == pb: return true
    case (.Deleted(let a, let pa), .Deleted(let b, let pb)) where a == b && pa == pb: return true
    default: return false
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
