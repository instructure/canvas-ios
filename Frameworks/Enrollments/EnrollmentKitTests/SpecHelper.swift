
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
    
    

@testable import EnrollmentKit
import Quick
import Nimble
import SoAutomated
import CoreData
import Marshal
import TooLegit
import ReactiveCocoa

extension CourseSpec {
    var validCourseJSON: JSONObject {
        return [
            "id": 1,
            "name": "Course 1",
            "course_code": "xyz",
            "is_favorite": true,
            "hide_final_grades": false,
            "default_view": "feed",
            "enrollments": [
                [
                    "type": "student",
                    "computed_current_grade": "A",
                    "computed_current_score": 100,
                    "computed_final_grade": "B",
                    "computed_final_score": 80,
                ],
                ["type": "teacher"],
                ["type": "observer"],
                ["type": "ta"],
                ["type": "designer"],
            ],
        ]
    }

    var mgpCourseJSON: JSONObject {
        var json = validCourseJSON
        json["enrollments"] = [
            [
                "type": "student",
                "current_grading_period_id": 1,
                "multiple_grading_periods_enabled": true,
                "current_period_computed_current_grade": "F",
                "current_period_computed_current_score": 50,
                "current_period_computed_final_grade": "D",
                "current_period_computed_final_score": 60,
                "totals_for_all_grading_periods_option": true,
            ]
        ]
        return json
    }
}
