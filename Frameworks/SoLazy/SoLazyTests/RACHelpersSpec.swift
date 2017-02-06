//
//  RACHelpersSpec.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 12/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble
import SoLazy
import ReactiveSwift
import Result
import SoAutomated

class RACHelpersSpec: QuickSpec {
    override func spec() {
        describe("accumulate") {
            it("should gather all next values into a single array") {
                let property = MutableProperty<Int>(0)
                let values = TestObserver<[Int], NoError>()
                property.signal.accumulate().observe(values.observer)

                property.value = 1
                values.assertValues([[1]])

                property.value = 2
                property.value = 3
                values.assertValues([[1], [1,2], [1,2,3]])
            }
        }
    }
}
