//
//  SpecHelper.swift
//  SoEdventurous
//
//  Created by Nathan Armstrong on 9/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

    static var jsonWithMasteryPaths: JSONObject {
        var json = validJSON
        json["mastery_paths"] = [
            "locked": true,
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
