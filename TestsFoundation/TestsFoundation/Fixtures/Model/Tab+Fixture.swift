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
import Core

extension Tab: Fixture {
    public static var template: Template {
        return[
            "id": "home",
            "htmlURL": URL(string: "https://twilson.instructure.com/groups/16")!,
            "position": 1,
            "label": "Home",
            "contextRaw": "group_1",
            "visibilityRaw": "public",
            "typeRaw": "internal",
        ]
    }
}
