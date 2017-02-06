//
//  Accumulate.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 1/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import ReactiveSwift

extension SignalProtocol {
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> Signal<[Value], Error> {
        return scan([]) { accum, action in
            accum + [action]
        }
    }
}

extension SignalProducerProtocol {
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> SignalProducer<[Value], Error> {
        return lift { $0.accumulate() }
    }
}
