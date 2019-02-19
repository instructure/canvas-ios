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

extension Enrollment: Fixture {
    public static var template: Template {
        return [
            "typeRaw": "student",
            "roleRaw": "StudentEnrollment",
            "roleID": "3",
            "userID": "1",
            "stateRaw": "active",
            "canvasContextID": "course_1",
//            "computed_current_score": 74.38,
//            "computed_final_score": 49.03,
//            "computed_current_grade": null,
//            "computed_final_grade": null,
//            "has_grading_periods": true,
//            "multiple_grading_periods_enabled": true,
//            "totals_for_all_grading_periods_option": true,
//            "current_grading_period_title": "Forever",
//            "current_grading_period_id": "1",
//            "current_period_computed_current_score": 74.38,
//            "current_period_computed_final_score": 49.03,
//            "current_period_computed_current_grade": null,
//            "current_period_computed_final_grade": null
        ]
    }
}
