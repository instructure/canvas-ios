//
//  NSDateSpec.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 11/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble
import SoAutomated
import SoLazy

class NSDateSpec: QuickSpec {
    override func spec() {
        describe("NSDate") {
            describe("range") {
                it("is not the same as adding day components") {
                    let start = NSDate(year: 2016, month: 11, day: 6)
                    let end = NSDate(year: 2016, month: 11, day: 13)
                    let weekRange = start..<end
                    let one = weekRange[1]
                    let two = start + 1.daysComponents
                    expect(one) != two
                }
            }
        }
    }
}
