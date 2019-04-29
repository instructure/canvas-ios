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

import Foundation
@testable import Core

extension Rubric: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "points": 25.0,
            "desc": "Effort",
            "longDesc": "Did you even try?",
            "criterionUseRange": false,
            "assignmentID": "2",
            "ratings": Set( [ RubricRating.make(["id": "1", "points": 10.0]), RubricRating.make(["id": "2", "points": 25.0])] ),
        ]
    }
}

extension RubricRating: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "points": 25.0,
            "desc": "Great!",
            "longDesc": "You did great!!",
            "assignmentID": "2",
        ]
    }
}

extension RubricAssessment: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "ratingID": "2",
            "comments": "random comment",
            "points": 25.0,
            "submissionID": "1",
        ]
    }
}
