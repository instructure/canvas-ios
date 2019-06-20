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

public enum LoginFindSchool: String, ElementWrapper {
    case searchField
}

public enum LoginFindAccountResult {
    public static var emptyCell: Element {
        return app.find(id: "LoginFindAccountResult.emptyCell")
    }

    public static func item(host: String) -> Element {
        return app.find(id: "LoginFindAccountResult.\(host)")
    }
}
