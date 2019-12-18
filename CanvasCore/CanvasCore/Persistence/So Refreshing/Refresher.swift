//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import ReactiveSwift
import Core

public protocol Refresher: class {
    var cacheKey: String { get }

    func makeRefreshable(_ viewController: UIViewController)

    func refresh(_ forced: Bool)

    func cancel()

    func safeCopy() -> Refresher?

    var isRefreshing: Bool { get }
    var refreshingBegan: Signal<(), Never> { get set }
    var refreshingCompleted: Signal<NSError?, Never> { get set }

    var refreshControl: UIRefreshControl { get }
}

import ReactiveSwift

open class SignalProducerRefresher<Value>: NSObject, Refresher {

    @objc public let refreshControl = UIRefreshControl()
    let signalProducer: SignalProducer<Value, NSError>
    var disposable: Disposable?

    @objc public let cacheKey: String
    @objc weak var scope: RefreshScope?
    @objc let ttl: TimeInterval

    @objc fileprivate (set) open var isRefreshing: Bool = false
    open var refreshingBegan: Signal<(), Never>
    var refreshingBeganObserver: Signal<(), Never>.Observer
    open var refreshingCompleted: Signal<NSError?, Never>
    var refreshingCompletedObserver: Signal<NSError?, Never>.Observer

    @objc open var shouldRefresh: Bool {
        if let scope = scope, scope.shouldRefreshCache(cacheKey, ttl: ttl) {
            return true
        }
        return false
    }

    /** Uses a signal to refresh.
     *
     * - param refreshSignalProducer The producer to invoke in order to sync the data
     * - param cacheKey The unique key for the cache. __MUST BE UNIQUE TO THE REQUEST__
     */
    public init(refreshSignalProducer: SignalProducer<Value, NSError>, scope: RefreshScope, cacheKey: String, ttl: TimeInterval = 2.hours) {
        self.scope = scope
        self.cacheKey = cacheKey
        self.ttl = ttl
        self.signalProducer = refreshSignalProducer

        let (beganSignal, beganObserver) = Signal<(), Never>.pipe()
        self.refreshingBegan = beganSignal.observe(on: UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, Never>.pipe()
        self.refreshingCompleted = completedSignal.observe(on: UIScheduler())
        self.refreshingCompletedObserver = completedObserver

        super.init()

        scope.register(self)
    }

    @objc open func makeRefreshable(_ viewController: UIViewController) {
        guard viewController.isViewLoaded else { return }
        refreshControl.addTarget(self, action: #selector(beginRefresh(_:)), for: .valueChanged)
        if let tv = viewController as? UITableViewController {
            tv.refreshControl = refreshControl
        } else if let cv = viewController as? UICollectionViewController {
            cv.collectionView?.alwaysBounceVertical = true
            cv.collectionView?.addSubview(refreshControl)
        } else if let scrollView = viewController.view as? UIScrollView {
            scrollView.alwaysBounceVertical = true
            scrollView.refreshControl = refreshControl
        } else {
            fatalError("Can't do it. Sorry.")
        }
        refreshControl.layoutIfNeeded()
    }

    @objc open func refresh(_ forced: Bool) {
        guard forced || shouldRefresh else { return }
        performUIUpdate {
            self.refreshControl.beginRefreshing()

            if let scrollView = self.refreshControl.superview as? UIScrollView, forced || self.shouldRefresh {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - self.refreshControl.frame.size.height), animated: true)
            }

            self.beginRefresh(self.refreshControl)
        }
    }

    @objc open func cancel() {
        disposable?.dispose()
    }

    open func safeCopy() -> Refresher? {
        guard let scope = scope else { return nil }
        return SignalProducerRefresher(refreshSignalProducer: signalProducer, scope: scope, cacheKey: cacheKey, ttl: ttl)
    }

    deinit {
        scope?.unregister(self)
        disposable?.dispose()
    }

    @objc func beginRefresh(_ control: UIRefreshControl) {
        guard let scope = self.scope else { return }

        isRefreshing = true
        refreshingBeganObserver.send(value: ())

        let key = cacheKey
        let last = scope.lastCacheRefresh(key)
        scope.setCacheRefreshed(key)
        disposable = signalProducer
            .observe(on: UIScheduler())
            .start { [weak self] event in
                switch event {
                case .value(_): break

                case .completed:
                    self?.endRefreshing()
                    
                case .interrupted:
                    self?.endRefreshing()
                    // if the refresh was interrupted, assume the
                    // refresh was incomplete like the error case
                    scope.setCacheRefreshed(key, date: last)

                case .failed(let err):
                    self?.endRefreshing(error: err)
                    scope.setCacheRefreshed(key, date: last)
                }
        }
    }
    
    @objc func endRefreshing(error: NSError? = nil) {
        isRefreshing = false
        refreshControl.endRefreshing()
        refreshingCompletedObserver.send(value: error)
        disposable = nil
    }
}
