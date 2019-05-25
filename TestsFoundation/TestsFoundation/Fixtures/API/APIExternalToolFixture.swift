//
// Copyright (C) 2019-present Instructure, Inc.
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

extension APIExternalTool {
    public static func make(
        id: ID = "1",
        name: String = "External 1",
        domain: String? = nil,
        url: URL = URL(string: "canvas.instructure.com/external_tools/1")!
    ) -> APIExternalTool {
        return APIExternalTool(
            id: id,
            name: name,
            domain: domain,
            url: url
        )
    }
}
