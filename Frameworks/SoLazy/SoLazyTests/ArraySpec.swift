//
//  ArraySpec.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 10/31/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import SoLazy
import Quick
import Nimble

class ArraySpec: QuickSpec {
    override func spec() {
        describe("Array Extensions") {
            describe("findFirst") {
                it("should find the first element matching the test") {
                    expect(["1", "2", "3"].findFirst { $0 == "1" }) == "1"
                    expect([1, 2, 3].findFirst { $0 > 1 }) == 2
                    expect([1, 2, 3].findFirst { $0 < 3 }) == 1
                }

                it("should return nil if no elements are found") {
                    expect(["1", "2", "3"].findFirst { $0 == "4" }).to(beNil())
                    expect([1, 2, 3].findFirst { $0 > 4 }).to(beNil())
                    expect([1, 2, 3].findFirst { $0 < 0 }).to(beNil())

                    let empty: [Int] = []
                    expect(empty.findFirst { $0 != nil }).to(beNil())
                }
            }

            describe("any") {
                it("should return true if any of the elements match the test") {
                    expect(["1", "2", "3"].any { $0 == "1" }) == true
                    expect(["1", "2", "3"].any { $0 == "2" }) == true
                    expect(["1", "2", "3"].any { $0 == "4" }) == false
                }

                it("should return false if no test is given and the array is empty") {
                    let empty: [Int] = []
                    expect(empty.any()) == false
                }

                it("should return true if no test is given and the array is not empty") {
                    expect([1].any()) == true
                    expect(["1"].any()) == true
                }
            }
        }
    }
}
