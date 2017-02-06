//
//  Event-Extensions.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 1/12/17.
//  Copyright © 2017 instructure. All rights reserved.
//

import ReactiveSwift

internal extension Event {
    internal var isValue: Bool {
        if case .value = self {
            return true
        }
        return false
    }

    internal var isFailed: Bool {
        if case .failed = self {
            return true
        }
        return false
    }

    internal var isInterrupted: Bool {
        if case .interrupted = self {
            return true
        }
        return false
    }
}
