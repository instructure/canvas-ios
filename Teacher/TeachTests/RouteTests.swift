//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import TooLegit
import URITemplate
import Quick
import Nimble

class TwoPropertyViewController: UIViewController {
    var one = ""
    var two = ""
}

class RouteSpec: QuickSpec {
    override func spec() {
        describe("Route") {
            var route: Route!
            beforeEach {
                route = Route(.Detail, path: "/whatever/{one}/something/{two}") { action, session, params in
                    let vc = TwoPropertyViewController()
                    vc.one = params["one"] ?? "wut!?"
                    vc.two = params["two"] ?? "srsly?!"
                    return vc
                }
            }

            describe(".constructViewController") {
                context("when parameters are wrong") {
                    it("returns nil") {
                        var url = NSURL(string: "https://instructure.com")!
                        var vc = try! route.constructViewController({_ in }, session: Session.unauthenticated, url: url)
                        expect(vc).to(beNil())

                        url = NSURL(string: "http://instructure.com/foo")!
                        vc = try! route.constructViewController({_ in }, session: Session.unauthenticated, url: url)
                        expect(vc).to(beNil())

                        url = NSURL(string: "https://instructure.com/whatever/4125")!
                        vc = try! route.constructViewController({_ in }, session: Session.unauthenticated, url: url)
                        expect(vc).to(beNil())
                    }
                }

                context("when parameters are correct") {
                    var vc: TwoPropertyViewController?
                    beforeEach {
                        let url = NSURL(string: "https://instructure.com/whatever/32/something/cats")!
                        vc = try! route.constructViewController({_ in }, session: Session.unauthenticated, url: url) as? TwoPropertyViewController
                    }

                    it("returns the vc") {
                        expect(vc).toNot(beNil())
                    }

                    it("captures the template parameters") {
                        expect(vc?.one) == "32"
                        expect(vc?.two) == "cats"
                    }
                }
            }
        }
    }
}
