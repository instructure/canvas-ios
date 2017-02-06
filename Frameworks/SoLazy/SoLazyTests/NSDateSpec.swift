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

import Quick
import Nimble
import SoAutomated
import SoLazy

class NSDateSpec: QuickSpec {
    override func spec() {
        describe("Date") {
            describe("range") {
                it("is not the same as adding day components") {
                    let start = Date(year: 2016, month: 11, day: 6)
                    let end = Date(year: 2016, month: 11, day: 13)
                    let weekRange = start..<end
                    let one = weekRange[1]
                    let two = start + 1.daysComponents
                    expect(one) != two
                }
            }
        }
    }
}
