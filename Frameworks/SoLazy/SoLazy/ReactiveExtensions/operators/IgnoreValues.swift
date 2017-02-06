//
//  IgnoreValues.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 1/13/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import ReactiveSwift

public extension SignalProtocol {

    /**
     Creates a new signal that emits a void value for every emission of `self`.
     - returns: A new signal.
     */
    public func ignoreValues() -> Signal<Void, Error> {
        return signal.map { _ in () }
    }
}

public extension SignalProducerProtocol {

    /**
     Creates a new producer that emits a void value for every emission of `self`.
     - returns: A new producer.
     */
    public func ignoreValues() -> SignalProducer<Void, Error> {
        return lift { $0.ignoreValues() }
    }
}
