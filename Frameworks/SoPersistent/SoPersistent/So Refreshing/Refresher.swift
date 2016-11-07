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
import SoLazy
import TooLegit
import ReactiveCocoa
import Result

public protocol Refresher: class {
    var cacheKey: String { get }

    func makeRefreshable(viewController: UIViewController)

    func refresh(forced: Bool)

    func cancel()

    func safeCopy() -> Refresher?

    var isRefreshing: Bool { get }
    var refreshingBegan: Signal<(), NoError> { get set }
    var refreshingCompleted: Signal<NSError?, NoError> { get set }

    var refreshControl: UIRefreshControl { get }
}

import ReactiveCocoa

public class SignalProducerRefresher<SP: SignalProducerType where SP.Error == NSError>: NSObject, Refresher {

    public let refreshControl = UIRefreshControl()
    let signalProducer: SP
    var disposable: Disposable?

    public let cacheKey: String
    weak var scope: RefreshScope?
    let ttl: NSTimeInterval

    private (set) public var isRefreshing: Bool = false
    public var refreshingBegan: Signal<(), NoError>
    var refreshingBeganObserver: Observer<(), NoError>
    public var refreshingCompleted: Signal<NSError?, NoError>
    var refreshingCompletedObserver: Observer<NSError?, NoError>

    public var shouldRefresh: Bool {
        if let scope = scope where scope.shouldRefreshCache(cacheKey, ttl: ttl) {
            return true
        }
        return false
    }

    /** Uses a signal to refresh.
     *
     * - param refreshSignalProducer The producer to invoke in order to sync the data
     * - param cacheKey The unique key for the cache. __MUST BE UNIQUE TO THE REQUEST__
     */
    public init(refreshSignalProducer: SP, scope: RefreshScope, cacheKey: String, ttl: NSTimeInterval = 2.hours) {
        self.scope = scope
        self.cacheKey = cacheKey
        self.ttl = ttl
        self.signalProducer = refreshSignalProducer

        let (beganSignal, beganObserver) = Signal<(), NoError>.pipe()
        self.refreshingBegan = beganSignal.observeOn(UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, NoError>.pipe()
        self.refreshingCompleted = completedSignal.observeOn(UIScheduler())
        self.refreshingCompletedObserver = completedObserver

        super.init()

        scope.register(self)
    }

    public func makeRefreshable(viewController: UIViewController) {
        guard viewController.isViewLoaded() else { return }
        refreshControl.addTarget(self, action: #selector(beginRefresh(_:)), forControlEvents: .ValueChanged)
        if let tv = viewController as? UITableViewController {
            tv.refreshControl = refreshControl
        } else if let cv = viewController as? UICollectionViewController {
            cv.collectionView?.alwaysBounceVertical = true
            cv.collectionView?.addSubview(refreshControl)
        } else {
            ❨╯°□°❩╯⌢"Can't do it. Sorry."
        }
        refreshControl.layoutIfNeeded()
    }

    public func refresh(forced: Bool) {
        guard forced || shouldRefresh else { return }

        refreshControl.beginRefreshing()
        beginRefresh(refreshControl)
    }

    public func cancel() {
        disposable?.dispose()
    }

    public func safeCopy() -> Refresher? {
        guard let scope = scope else { return nil }
        return SignalProducerRefresher(refreshSignalProducer: signalProducer, scope: scope, cacheKey: cacheKey, ttl: ttl)
    }

    deinit {
        scope?.unregister(self)
        disposable?.dispose()
    }

    func beginRefresh(control: UIRefreshControl) {
        guard let scope = self.scope else { return }

        isRefreshing = true
        refreshingBeganObserver.sendNext()

        let last = scope.lastCacheRefresh(cacheKey)
        scope.setCacheRefreshed(cacheKey)
        disposable = signalProducer
            .observeOn(UIScheduler())
            .start { [weak self] event in
                self?.isRefreshing = false
                switch event {
                case .Next(_): break

                case .Completed, .Interrupted:
                    control.endRefreshing()
                    self?.refreshingCompletedObserver.sendNext(nil)
                    self?.disposable = nil

                case .Failed(let err):
                    control.endRefreshing()
                    self?.refreshingCompletedObserver.sendNext(err)
                    self?.disposable = nil

                    if let me = self {
                        // reset the cache ttl date if refresh failed
                        scope.setCacheRefreshed(me.cacheKey, date: last)
                    }
                }
        }
    }
}