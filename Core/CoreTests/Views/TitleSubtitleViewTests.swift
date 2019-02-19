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

class TitleSubtitleViewTests: XCTestCase {
    func testCreate() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.titleLabel?.text, "")
        XCTAssertEqual(view.titleLabel?.textColor, .named(.white))
        XCTAssertEqual(view.subtitleLabel?.text, "")
        XCTAssertEqual(view.subtitleLabel?.textColor, .named(.white))
    }

    func testTitle() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.title, view.titleLabel?.text)
        view.title = "title"
        XCTAssertEqual(view.title, "title")
        XCTAssertEqual(view.titleLabel?.text, "title")
    }

    func testSubtitle() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.subtitle, view.subtitleLabel?.text)
        view.subtitle = "subtitle"
        XCTAssertEqual(view.subtitle, "subtitle")
        XCTAssertEqual(view.subtitleLabel?.text, "subtitle")
    }
}
