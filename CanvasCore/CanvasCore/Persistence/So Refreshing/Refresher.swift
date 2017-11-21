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
import Result

public protocol Refresher: class {
    var cacheKey: String { get }

    func makeRefreshable(_ viewController: UIViewController)

    func refresh(_ forced: Bool)

    func cancel()

    func safeCopy() -> Refresher?

    var isRefreshing: Bool { get }
    var refreshingBegan: Signal<(), NoError> { get set }
    var refreshingCompleted: Signal<NSError?, NoError> { get set }

    var refreshControl: UIRefreshControl { get }
}

import ReactiveSwift

open class SignalProducerRefresher<SP: SignalProducerProtocol>: NSObject, Refresher where SP.Error == NSError {

    open let refreshControl = UIRefreshControl()
    let signalProducer: SP
    var disposable: Disposable?

    open let cacheKey: String
    weak var scope: RefreshScope?
    let ttl: TimeInterval

    fileprivate (set) open var isRefreshing: Bool = false
    open var refreshingBegan: Signal<(), NoError>
    var refreshingBeganObserver: Observer<(), NoError>
    open var refreshingCompleted: Signal<NSError?, NoError>
    var refreshingCompletedObserver: Observer<NSError?, NoError>

    open var shouldRefresh: Bool {
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
    public init(refreshSignalProducer: SP, scope: RefreshScope, cacheKey: String, ttl: TimeInterval = 2.hours) {
        self.scope = scope
        self.cacheKey = cacheKey
        self.ttl = ttl
        self.signalProducer = refreshSignalProducer

        let (beganSignal, beganObserver) = Signal<(), NoError>.pipe()
        self.refreshingBegan = beganSignal.observe(on: UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, NoError>.pipe()
        self.refreshingCompleted = completedSignal.observe(on: UIScheduler())
        self.refreshingCompletedObserver = completedObserver

        super.init()

        scope.register(self)
    }

    open func makeRefreshable(_ viewController: UIViewController) {
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
            ❨╯°□°❩╯⌢"Can't do it. Sorry."
        }
        refreshControl.layoutIfNeeded()
    }

    open func refresh(_ forced: Bool) {
        guard forced || shouldRefresh else { return }

        refreshControl.beginRefreshing()

        if let scrollView = refreshControl.superview as? UIScrollView, forced || shouldRefresh {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - refreshControl.frame.size.height), animated: true)
        }

        beginRefresh(refreshControl)
    }

    open func cancel() {
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

    func beginRefresh(_ control: UIRefreshControl) {
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
    
    func endRefreshing(error: NSError? = nil) {
        isRefreshing = false
        refreshControl.endRefreshing()
        refreshingCompletedObserver.send(value: error)
        disposable = nil
    }
}
