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

class BundleExtensionsTests: XCTestCase {
    func testLoadView() {
        let view = Bundle.loadView(TitleSubtitleView.self)
        XCTAssertNotNil(view)
    }

    func testLoadController() {
        XCTAssertNotNil(Bundle.loadController(DocViewerViewController.self))
    }

    func testIsApp() {
        XCTAssertFalse(Bundle.core.isParentApp)
        XCTAssertFalse(Bundle.core.isStudentApp)
        XCTAssertFalse(Bundle.core.isTeacherApp)
    }

    func testAppGroupID() {
        XCTAssertNil(Bundle.main.appGroupID())
        XCTAssertEqual(Bundle.main.appGroupID(bundleID: Bundle.studentBundleID), "group.com.instructure.icanvas")
    }
}
