//
//  JSONShapeSpec.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/22/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import SoAutomated
import Quick
import Nimble

class JSONShapeSpec: QuickSpec {
    override func spec() {
        describe("JSONShape") {
            describe("matching values") {
                var shape: JSONShape!
                beforeEach {
                    shape = ["id"]
                }

                it("finds match") {
                    let json: [String: AnyObject] = ["id": 1]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds mismatch") {
                    let json: [String: AnyObject] = [:]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "id"
                }

                it("finds a match with an array of matching objects") {
                    let json: [[String: AnyObject]] = [["id": 1]]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds a mismatch with an array of matching objects") {
                    let json: [[String: AnyObject]] = [[:]]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "id"
                }
            }

            describe("matching objects") {
                var shape: JSONShape!
                beforeEach {
                    shape = [
                        object("object", [
                            "id"
                        ])
                    ]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [
                        "object": [
                            "id": 1
                        ]
                    ]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds missing object") {
                    let json: [String: AnyObject] = [:]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "object"
                }

                it("finds missing object value") {
                    let json: [String: AnyObject] = [
                        "object": [:]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "id"
                }
            }

            describe("matching inner objects") {
                var shape: JSONShape!
                beforeEach {
                    shape = [
                        object("contact_info", [
                            object("address", ["city", "state"])
                        ])
                    ]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [
                        "contact_info": [
                            "address": [
                                "city": "SLC",
                                "state": "UT"
                            ]
                        ]
                    ]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds missing inner object") {
                    let json: [String: AnyObject] = ["contact_info": [:]]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "address"
                }

                it("finds missing inner object value") {
                    let json: [String: AnyObject] = ["contact_info": ["address": ["city": "San Francisco"]]]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "state"
                }
            }

            it("matches arrays of values") {
                let json = ["friends": ["alice", "bob", "charlie"]]
                let shape: JSONShape = ["friends"]
                expect(json).to(beShapedLike(shape))
            }

            describe("matching arrays of objects") {
                var shape: JSONShape!
                beforeEach {
                    shape = [
                        objects("friends", [
                            "name",
                            "age"
                        ])
                    ]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [
                        "friends": [
                            ["name": "alice", "age": 21],
                            ["name": "bob", "age": 30]
                        ]
                    ]
                    expect(json).to(beShapedLike(shape))
                }

                it("expects value to be an array of objects") {
                    let json: [String: AnyObject] = [
                        "friends": ["alice", "age"]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "friends"
                }

                it("finds missing array object key") {
                    let json: [String: AnyObject] = [
                        "friends": [
                            ["name": "alice"]
                        ]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "age"
                }
            }

            describe("matching inner arrays") {
                var shape: JSONShape!
                beforeEach {
                    shape = [
                        objects("friends", [
                            objects("pets", [
                                "species",
                                "name"
                            ])
                        ])
                    ]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [
                        "friends": [
                            ["pets": [["name": "fido", "species": "dog"], ["name": "mittens", "species": "cat"]]]
                        ]
                    ]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds mismatch") {
                    let json: [String: AnyObject] = [
                        "friends": [
                            ["pets": [["name": "fido", "species": "dog"], ["name": "fido"]]]
                        ]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "species"
                }
            }

            describe("mathing objects containing arrays of objects") {
                var shape: JSONShape!
                beforeEach {
                    shape = [
                        object("parent", [
                            objects("pets", [
                                "species",
                                "name"
                            ])
                        ])
                    ]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [
                        "parent": [
                            "pets": [["species": "dog", "name": "choco"]]
                        ]
                    ]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds mismatched object type") {
                    let json: [String: AnyObject] = [
                        "parent": "mom"
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "parent"
                }

                it("finds mismatched array type") {
                    let json: [String: AnyObject] = [
                        "parent": [
                            "pets": "choc, fido, bell"
                        ]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "pets"
                }

                it("finds mismatched array object") {
                    let json: [String: AnyObject] = [
                        "parent": [
                            "pets": ["species": "dog", "name": "choco"]
                        ]
                    ]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "pets"
                }
            }

            describe("specifying keys that should not exist") {
                var shape: JSONShape!
                beforeEach {
                    shape = [!"name"]
                }

                it("finds match") {
                    let json: [String: AnyObject] = [:]
                    expect(json).to(beShapedLike(shape))
                }

                it("finds mismatch") {
                    let json: [String: AnyObject] = ["name": "alice"]
                    let (matches, key) = jsonShape(shape, matchesObject: json)
                    expect(matches) == false
                    expect(key) == "!name"
                }
            }
        }
    }
}
