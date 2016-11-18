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

import Marshal
@testable import SoEdventurous

private class Bundle {}
let currentBundle = NSBundle(forClass: Bundle.self)

extension Module {
    static var validJSON: JSONObject {
        return [
            "id": 1,
            "course_id": 1,
            "name": "Module 1",
            "prerequisite_module_ids": []
        ]
    }

    static var jsonWithQuizModuleItem: JSONObject {
        let path = NSBundle(forClass: Bundle.self).pathForResource("module__quiz_module_item", ofType: "json")!
        let data = NSData(contentsOfURL: NSURL(fileURLWithPath: path))!
        var json = try! JSONParser.JSONObjectWithData(data)
        json["course_id"] = 1
        return json
    }
}

extension ModuleItem {
    static var validJSON: JSONObject {
        return [
            "id": 1,
            "course_id": 1,
            "module_id": 1,
            "type": "SubHeader"
        ]
    }

    static func jsonWithMasteryPaths(locked locked: Bool = true) -> JSONObject {
        var json = validJSON
        json["mastery_paths"] = [
            "locked": locked,
            "assignment_sets": [
                [
                    "id": 1,
                    "position": 0,
                    "assignments": [
                        [
                            "id": 1,
                            "assignment_id": 1,
                            "assignment_set_id": 1,
                            "position": 0,
                            "model": [
                                "name": "Assignment 1",
                                "submission_types": ["online_quiz"]
                            ]
                        ]
                    ]
                ]
            ]
        ]
        return json
    }
}
