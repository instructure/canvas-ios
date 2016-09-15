//
//  SimpleRefresher.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import ReactiveCocoa
import Result

class SimpleRefresher: Refresher {
    
    var cacheKey = "simple"
    var makeRefreshableWasCalled = false
    var refreshWasCalled = false
    var cancelWasCalled = false

    var refreshControl = UIRefreshControl()
    var isRefreshing: Bool = false
    var refreshingBegan: Signal<(), NoError>
    var refreshingBeganObserver: Observer<(), NoError>
    var refreshingCompleted: Signal<NSError?, NoError>
    var refreshingCompletedObserver: Observer<NSError?, NoError>

    init() {
        let (beganSignal, beganObserver) = Signal<(), NoError>.pipe()
        self.refreshingBegan = beganSignal.observeOn(UIScheduler())
        self.refreshingBeganObserver = beganObserver

        let (completedSignal, completedObserver) = Signal<NSError?, NoError>.pipe()
        self.refreshingCompleted = completedSignal.observeOn(UIScheduler())
        self.refreshingCompletedObserver = completedObserver
    }

    func makeRefreshable(viewController: UIViewController) {
        makeRefreshableWasCalled = true
    }

    func refresh(forced: Bool) {
        refreshWasCalled = true
    }

    func cancel() {
        cancelWasCalled = true
    }

    func safeCopy() -> Refresher? {
        let copy = SimpleRefresher()
        return copy
    }
}
