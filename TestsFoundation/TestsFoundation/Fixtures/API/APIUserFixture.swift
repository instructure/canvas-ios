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

@testable import Core

extension APIUser: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "name": "Bob",
            "sortable_name": "Bob",
            "short_name": "Bob",
            "effective_locale": "en",
        ]
    }
}

extension APIUser: APIContext {
    public var contextType: ContextType { return .user }
}

extension APIUserSettings: Fixture {
    public static var template: Template {
        return [
            "manual_mark_as_read": false,
            "collapse_global_nav": false,
            "hide_dashcard_color_overlays": false
        ]
    }
}
