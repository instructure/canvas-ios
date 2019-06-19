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

enum CourseNavigation {
    static var grades: Element {
        return app.find(id: "courses-details.grades-cell")
    }

    static var announcements: Element {
        return app.find(id: "courses-details.announcements-cell")
    }

    static var people: Element {
        return app.find(id: "courses-details.people-cell")
    }

    static var files: Element {
        return app.find(id: "courses-details.files-cell")
    }
}
