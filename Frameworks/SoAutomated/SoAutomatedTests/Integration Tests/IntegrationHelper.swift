//
//  IntegrationHelper.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 10/11/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Nimble

let timeout: NSTimeInterval = 5

extension SignalProducerType {
    public func waitUntilFirst() -> Value? {
        var value: Value?
        waitUntil(timeout: timeout) { done in
            self.start { event in
                switch event {
                case .Next(let v):
                    value = v
                    done()
                case .Completed:
                    break
                case .Interrupted:
                    fail("interrupted")
                case .Failed(let error):
                    fail("failed with error \(stringify(error))")
                }
            }
        }
        return value
    }
}
