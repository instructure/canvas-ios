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

extension APITab {
    public static func make(
        id: ID = "home",
        html_url: URL = URL(string: "/groups/16")!,
        label: String = "Home",
        type: TabType = .internal,
        hidden: Bool? = nil,
        visibility: TabVisibility = .public,
        position: Int = 1
    ) -> APITab {
        return APITab(
            id: id,
            html_url: html_url,
            label: label,
            type: type,
            hidden: hidden,
            visibility: visibility,
            position: position
        )
    }
}
