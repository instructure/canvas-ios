//
// Copyright (C) 2018-present Instructure, Inc.
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

import XCTest
@testable import Core

class GetCustomColorsTests: CoreTestCase {
    func testSuccess() {
        Color.make([ "canvasContextID": "course_8", "color": UIColor.named(.electric) ])
        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [ "course_1": "#000", "course_2": "invalid" ]))
        addOperationAndWait(GetCustomColors(env: environment, force: true))
        let colors: [Color] = databaseClient.fetch(.all)
        XCTAssertEqual(colors.count, 1)
        XCTAssertEqual(colors[0].color.hexString, "#000000")
    }

    func testSaveNil() {
        let color = Color.make()
        XCTAssertNoThrow(try GetCustomColors(env: environment, force: true).save(response: nil, urlResponse: nil, client: databaseClient))
        let colors: [Color] = databaseClient.fetch(.all)
        XCTAssertEqual(colors, [color])
    }
}
