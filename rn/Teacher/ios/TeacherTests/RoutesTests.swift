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
import Core
@testable import Teacher
import TestsFoundation

class RoutesTests: TeacherTestCase {
    func testModules() {
        XCTAssert(Teacher.router.match(Route.modules(forCourse: "1").url) is ModuleListViewController)
    }

    func testModule() {
        XCTAssert(Teacher.router.match(Route.module(forCourse: "1", moduleID: "2").url) is ModuleListViewController)
    }
}
