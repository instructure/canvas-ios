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

extension APIUser {
    public static func make(
        id: ID = "1",
        name: String = "Bob",
        sortable_name: String = "Bob",
        short_name: String = "Bob",
        login_id: String? = nil,
        avatar_url: URL? = nil,
        email: String? = nil,
        locale: String? = "en",
        effective_locale: String? = nil,
        bio: String? = nil
    ) -> APIUser {
        return APIUser(
            id: id,
            name: name,
            sortable_name: sortable_name,
            short_name: short_name,
            login_id: login_id,
            avatar_url: avatar_url,
            email: email,
            locale: locale,
            effective_locale: effective_locale,
            bio: bio
        )
    }
}

extension APIUser: APIContext {
    public var contextType: ContextType { return .user }
}

extension APIUserSettings {
    public static func make(
        manual_mark_as_read: Bool = false,
        collapse_global_nav: Bool = false,
        hide_dashcard_color_overlays: Bool = false
    ) -> APIUserSettings {
        return APIUserSettings(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays
        )
    }
}
