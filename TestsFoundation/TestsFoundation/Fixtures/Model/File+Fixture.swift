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

extension File: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "uuid": "uuid-1234",
            "folderID": "1",
            "displayName": "File",
            "filename": "File.jpg",
            "contentType": "image/jpeg",
            "url": URL(string: "https://canvas.instructure.com/files/1/download"),
            "size": 1024,
            "createdAt": Date(),
            "updatedAt": Date(),
            "locked": false,
            "hidden": false,
            "hiddenForUser": false,
            "mimeClass": "JPEG",
            "lockedForUser": false
        ]
    }
}
