//
//  Errors.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 12/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//


import ReactiveSwift
import Result

extension SignalProtocol where Value: EventProtocol, Error == NoError {
    /**
     - returns: A signal of errors of `Error` events from a materialized signal.
     */
    public func errors() -> Signal<Value.Error, NoError> {
        return self.signal.map { $0.event.error }.skipNil()
    }
}

extension SignalProducerProtocol where Value: EventProtocol, Error == NoError {
    /**
     - returns: A producer of errors of `Error` events from a materialized signal.
     */
    public func errors() -> SignalProducer<Value.Error, NoError> {
        return self.lift { $0.errors() }
    }
}
