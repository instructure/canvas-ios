
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
    
    

import SoAutomated
import Quick
import Nimble

// Fixes "library not loaded" error with simulator.
import AVFoundation
import WebKit

class ChangeSpec: QuickSpec {
    override func spec() {
        describe("change") {
            it("verifies change") {
                var count = 0
                expect { count = 1 }.to(change { count } )
                expect { count = 1 }.toNot(change { count })
            }
        }

        describe("change(by:)") {
            it("verifies change") {
                var count = 0
                expect { count += 1 }.to(change({ count }, by: 1))
                expect { count += 1 }.toNot(change({ count }, by: 3))
            }
        }

        describe("change(from:to:)") {
            it("verifies change") {
                var count = 0
                expect { count += 1 }.to(change({ count }, from: 0, to: 1))

                var s = ""
                expect { s = "foo" }.to(change({ s }, from: "", to: "foo"))
                expect { s = "bar" }.toNot(change({ s }, from: "foo", to: "baz"))
                expect { s = "baz" }.toNot(change({ s }, from: "foo", to: "baz"))
            }

            it("should allow changing to and from nil") {
                var s: String? = nil
                expect { s = "foo" }.to(change({ s }, from: nil, to: "foo"))
                expect { s = nil }.to(change({ s }, from: "foo", to: nil))
            }
        }

        describe("change(to:)") {
            it("verifies change") {
                var count = 0
                expect { count += 1 }.to(change({ count }, to: 1))
                expect { count += 1 }.toNot(change({ count }, to: 3))
            }
            
            it("fails if the value does not change") {
                var s = "bar"
                expect { s = "bar" }.toNot(change({ s }, to: "bar"))
            }
        }
    }
}
