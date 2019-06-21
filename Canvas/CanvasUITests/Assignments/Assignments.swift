//
// Copyright (C) 2019-present Instructure, Inc.
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
import TestsFoundation

enum GradesList {
    static var title: Element {
        return app.find(label: "Grades")
    }

    static func assignment(id: String) -> Element {
        return app.find(id: "grades-list.grades-list-row.cell-\(id)")
    }
}

enum AssignmentDetails {
    static func description(_ description: String) -> Element {
        return app.find(label: description)
    }

    static func link(_ description: String) -> Element {
        return XCUIElementWrapper(app.webViews.staticTexts[description])
    }
}
