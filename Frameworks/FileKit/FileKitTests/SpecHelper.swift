//
//  SpecHelper.swift
//  FileKit
//
//  Created by Nathan Armstrong on 10/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import Marshal

private class Bundle {}
let currentBundle = NSBundle(forClass: Bundle.self)

let folderJSON: JSONObject = [
    "id": "1",
    "name": "Steve",
    "hidden_for_user": false,
    "files_url": "https://mobiledev.instructure.com/api/v1/folders/10017868/folders",
    "folders_url": "https://mobiledev.instructure.com/api/v1/folders/10017868/folders",
    "files_count": 10,
    "folders_count": 10
]
